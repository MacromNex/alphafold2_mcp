FROM python:3.10-slim AS builder

RUN apt-get update && apt-get install -y \
    git gcc g++ wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
RUN pip install --no-cache-dir --prefix=/install --ignore-installed fastmcp

# Clone AlphaFold repository (not in git, so clone during build)
RUN git clone https://github.com/deepmind/alphafold.git /app/repo/alphafold

# Download AlphaFold2 model parameters during build to avoid repeated downloads
RUN mkdir -p /app/data/params \
    && wget -q https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar \
       -O /tmp/alphafold_params.tar \
    && tar xf /tmp/alphafold_params.tar -C /app/data/params \
    && rm /tmp/alphafold_params.tar

FROM python:3.10-slim AS runtime

RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /install /usr/local
COPY --from=builder /app/data /app/data
COPY --from=builder /app/repo /app/repo
COPY src/ ./src/
RUN chmod -R a+r /app/src/
COPY scripts/ ./scripts/
RUN chmod -R a+r /app/scripts/

RUN mkdir -p tmp/inputs tmp/outputs

ENV PYTHONPATH=/app
ENV AF2_DATA_DIR=/app/data

CMD ["python", "src/server.py"]
