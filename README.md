# PSE Pipeline

An automated daily pipeline that scrapes, processes, and visualizes public equity market data from all PSE listed companies.

## Background

This started as a personal project. After leaving a prop trading role, I lost access to tools I used daily which are expensive to maintain as an independent trader. I built this to replace those while keeping overhead cost zero. The original version was a manual Power BI dashboard. Functional, but fully manual. This is the proper rebuild: automated, cloud-hosted, and free to run. The DE Zoomcamp I am currently taking pushed me to finally build this properly. I did not follow the curriculum's promoted tools since I just wanted this to be straightforward and light. This project was a side quest that became a good implementation exercise.

## Architecture

<img alt="architecture" src=".docs/01 architecture.png" />

**Flow:** PSE EDGE → Scrapers → Supabase → DuckDB → Supabase → Power BI

**Schedule:** GitHub Actions cron, daily 2AM Philippine Time

## Pipeline

### 1. Collect — `pse_pipeline_price.py` and `pse_pipeline_meta.py`

Two scrapers built with AI targeting [PSE EDGE](https://edge.pse.com.ph):

- **Price** — OHLCV data for all 283 listed companies, incremental updates (only fetches from last known date)
- **Meta** — Company info, stock data, and financial statements (balance sheet, income statement) scraped per company page

Both include rate limiting and error handling to survive partial failures.

Output: individual `.parquet` files per ticker → uploaded to `pse-price` and `pse-meta` Supabase buckets.

<img alt="input" src=".docs/02 input.png" />

### 2. Process — `pse_pipeline_duckdb.py`

DuckDB reads raw parquet files directly from Supabase storage via S3.

A CTE chain handles the full transformation in one pass:

- Union all ticker price files then join with meta
- Clean and cast types, normalize financial figures and headers
- Compute indicators at 3 timeframes (20 / 60 / 240 day) using window functions
- Derive rolling highs/lows, breadth indicators, breakout/breakdown/behavioral alerts
- Aggregate to industry and sector level with profitability, valuation, and breadth rankings

Output: `pse_clean_price`, `pse_clean_meta`, `pse_clean_agg` as both `.parquet` and `.csv` → uploaded to `pse-clean` Supabase bucket (public).

<img alt="output price" src=".docs/05a output price df.png" />
<img alt="output meta" src=".docs/05b output meta df.png" />
<img alt="output agg" src=".docs/05c output agg df.png" />

### 3. Automate — GitHub Actions

All three scripts run sequentially in Docker containers. Supabase credentials are stored as GitHub Secrets.

<img alt="automation" src=".docs/03 automation.png" />

### 4. Visualize — Power BI

Power BI connects directly to the public Supabase CSV URLs. Dashboard auto-refreshes on each pipeline run.

<img alt="schema" src=".docs/06a schema relations.png" />
<img alt="overview" src=".docs/06b overview.png" />
<img alt="matrix" src=".docs/06c matrix.png" />
<img alt="trend" src=".docs/06d trend.png" />

## Stack

| Layer | Tool | Why |
|---|---|---|
| Scraping | AI + Python | PSE EDGE has no public API |
| Processing | DuckDB | Reads parquet directly using S3, CTE chain transforms without a running database |
| Storage | Supabase Storage | Free tier comfortably fits a 300-ticker dataset; public URL feeds Power BI directly |
| Orchestration | GitHub Actions | Sufficient for a single sequential job; no infrastructure to maintain |
| Packaging | Docker + uv | Reproducible environment, fast dependency installs |
| Visualization | Power BI | Auto-refresh via web URL |

## Decisions

**GitHub Actions over Kestra**: The pipeline is a single sequential job. A cron-triggered Actions workflow is simpler and free. Perfect for this scale.

**DuckDB over Pandas**: DuckDB reads Parquet directly via S3 without loading everything into memory. CTE chain runs the full transformation in a single query.

**Parquet format**: Light and works well with DuckDB.
