FROM python:3.12.13-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
ENV PYTHONUNBUFFERED=1
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen
COPY pse_pipeline_price.py pse_pipeline_meta.py .
CMD ["uv", "run", "python", "pse_pipeline_price.py"]