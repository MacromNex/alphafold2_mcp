# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

AlphaFold2 MCP server — a FastMCP-based server exposing AlphaFold2 protein structure prediction as MCP tools. Supports monomer, multimer, and batch predictions via an async job submission API, plus synchronous utility tools.

## Setup

```bash
# Local (conda/mamba required)
bash quick_setup.sh

# Docker
docker build -t alphafold2-mcp .
docker run alphafold2-mcp
```

The Docker image pre-bakes AF2 model checkpoints (~3.5GB) at `/app/data/params/`. Genetic databases (600GB-2.6TB) must be volume-mounted at runtime.

## Running

```bash
# Start MCP server
env/bin/python src/server.py

# Register with Claude Code
claude mcp add alphafold2 -- ./env/bin/python ./src/server.py
```

## Testing

```bash
# Unit tests
env/bin/python test_server.py

# Integration tests (generates JSON report)
env/bin/python tests/run_integration_tests.py
```

Manual test prompts are documented in `tests/test_prompts.md`.

## Architecture

### Two-API Design

**Async (submit) API** for long-running predictions — tools return a `job_id` immediately:
- `submit_monomer_prediction`, `submit_multimer_prediction`, `submit_batch_prediction`
- Poll with `get_job_status`, `get_job_result`, `get_job_log`, `cancel_job`, `list_jobs`

**Sync API** for instant operations:
- `analyze_fasta_file`, `create_sample_data`, `get_server_info`

### Key Components

- **`src/server.py`** — MCP tool definitions (11 tools). Entry point via `mcp.run()`.
- **`src/jobs/manager.py`** — `JobManager` class. Spawns background threads, manages job lifecycle (pending→running→completed/failed), persists state as JSON in `jobs/<job_id>/`.
- **`scripts/{monomer,multimer,batch}_prediction.py`** — Prediction scripts executed as subprocesses by JobManager. Each builds an AlphaFold CLI command. Support `--production` flag (demo mode by default).
- **`scripts/lib/io.py`** — FASTA parsing/writing, complex type detection (homodimer/heterodimer/multimer).
- **`scripts/lib/utils.py`** — Command building (`build_alphafold_command`), resource estimation, sample sequence data.
- **`configs/`** — JSON configs for default, monomer, multimer, and batch settings.

### Data Flow

```
MCP Tool → JobManager.submit_job() → spawns thread → subprocess runs scripts/*.py
                                                        ↓
                                    jobs/<job_id>/metadata.json (status tracking)
                                    jobs/<job_id>/job.log (stdout/stderr)
                                    jobs/<job_id>/results/ (prediction output)
```

### Path Conventions

The server resolves paths relative to `src/server.py`:
- `SCRIPT_DIR` = `src/`
- `MCP_ROOT` = project root
- `SCRIPTS_DIR` = `scripts/`

`PYTHONPATH` must include the project root. In Docker this is set to `/app`.

### Demo Mode

Scripts default to demo mode (print commands without executing). Pass `--production` to actually run AlphaFold. The JobManager always appends `--production` when submitting jobs.

## CI/CD

GitHub Actions (`.github/workflows/docker.yml`) builds and pushes to GHCR on push to `main` or version tags. Uses multi-stage Docker build with registry-level build cache.

## Key Dependencies

FastMCP for MCP server framework, loguru for logging. AlphaFold deps: JAX, TensorFlow, BioPython, dm-haiku. The `repo/alphafold/` directory (gitignored) is cloned from `github.com/deepmind/alphafold` during setup/Docker build.

## Gotchas

- `repo/` is gitignored — it's cloned at setup time (quick_setup.sh) or Docker build time.
- `.gitignore` uses `/jobs/` (anchored) so `src/jobs/` is tracked but top-level `jobs/` (runtime data) is not.
- The `src/tools/` package exists but is currently empty — tools are defined directly in `server.py`.
