FROM python:3.12.13-slim
WORKDIR /app

# PostgreSQL dev libraries for psycopg2
RUN apt-get update && apt-get install -y libpq-dev && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Dependencies first (better layer caching)
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Scripts
COPY pse_pipeline_price.py pse_pipeline_meta.py pse_pipeline_duckdb.py .

ENV PYTHONUNBUFFERED=1

CMD ["uv", "run", "python", "pse_pipeline_price.py"]