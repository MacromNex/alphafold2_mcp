# AlphaFold2 MCP Server

**Protein structure prediction for monomers, multimers, and batch processing via Docker**

An MCP (Model Context Protocol) server for AlphaFold2 protein structure prediction with 5 core tools:
- Predict 3D structure of single proteins (monomers)
- Predict protein complexes (multimers)
- Batch process multiple proteins
- Submit long-running jobs and track their progress
- Analyze FASTA files and get recommendations

## Quick Start with Docker

### Approach 1: Pull Pre-built Image from GitHub

The fastest way to get started. A pre-built Docker image is automatically published to GitHub Container Registry on every release.

```bash
# Pull the latest image
docker pull ghcr.io/macromnex/alphafold2_mcp:latest

# Register with Claude Code (runs as current user to avoid permission issues)
claude mcp add alphafold2 -- docker run -i --rm --user `id -u`:`id -g` --gpus all --ipc=host -v `pwd`:`pwd` ghcr.io/macromnex/alphafold2_mcp:latest
```

**Note:** Run from your project directory. `` `pwd` `` expands to the current working directory.

**Requirements:**
- Docker with GPU support (`nvidia-docker` or Docker with NVIDIA runtime)
- Claude Code installed

That's it! The AlphaFold2 MCP server is now available in Claude Code.

---

### Approach 2: Build Docker Image Locally

Build the image yourself and install it into Claude Code. Useful for customization or offline environments.

```bash
# Clone the repository
git clone https://github.com/MacromNex/alphafold2_mcp.git
cd alphafold2_mcp

# Build the Docker image
docker build -t alphafold2_mcp:latest .

# Register with Claude Code (runs as current user to avoid permission issues)
claude mcp add alphafold2 -- docker run -i --rm --user `id -u`:`id -g` --gpus all --ipc=host -v `pwd`:`pwd` alphafold2_mcp:latest
```

**Note:** Run from your project directory. `` `pwd` `` expands to the current working directory.

**Requirements:**
- Docker with GPU support
- Claude Code installed
- Git (to clone the repository)

**About the Docker Flags:**
- `-i` — Interactive mode for Claude Code
- `--rm` — Automatically remove container after exit
- `` --user `id -u`:`id -g` `` — Runs the container as your current user, so output files are owned by you (not root)
- `--gpus all` — Grants access to all available GPUs
- `--ipc=host` — Uses host IPC namespace for better performance
- `-v` — Mounts your project directory so the container can access your data

---

## Verify Installation

After adding the MCP server, you can verify it's working:

```bash
# List registered MCP servers
claude mcp list

# You should see 'alphafold2' in the output
```

In Claude Code, you can now use all 5 AlphaFold2 tools:
- `submit_monomer_prediction`
- `submit_multimer_prediction`
- `submit_batch_prediction`
- `get_job_status`
- `get_job_result`

---

## Next Steps

- **Detailed documentation**: See [detail.md](detail.md) for comprehensive guides on:
  - Available MCP tools and parameters
  - Local Python environment setup (alternative to Docker)
  - Example workflows and use cases
  - Configuration file options
  - AlphaFold database setup

---

## Usage Examples

Once registered, you can use the AlphaFold2 tools directly in Claude Code. Here are some common workflows:

### Example 1: Monomer Structure Prediction

```
I have a protein sequence in /path/to/protein.fasta. Can you submit a monomer structure prediction using submit_monomer_prediction with the reduced_dbs preset and save results to /path/to/results/?
```

### Example 2: Protein Complex Prediction

```
I have two protein chains in /path/to/complex.fasta that I want to model as a heterodimer. Can you use submit_multimer_prediction to predict the complex structure and generate 5 prediction attempts?
```

### Example 3: Batch Processing

```
I have a directory of FASTA files at /path/to/sequences/ containing 10 proteins. Can you submit them for batch prediction using submit_batch_prediction and track the job status until they complete?
```

---

## Troubleshooting

**Docker not found?**
```bash
docker --version  # Install Docker if missing
```

**GPU not accessible?**
- Ensure NVIDIA Docker runtime is installed
- Check with `docker run --gpus all ubuntu nvidia-smi`

**Claude Code not found?**
```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code
```

**AlphaFold databases missing?**
- Download from the official AlphaFold database repository
- Use `reduced_dbs` preset for faster testing without full databases

---

## License

Based on [DeepMind AlphaFold](https://github.com/deepmind/alphafold) — Apache 2.0
