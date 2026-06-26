# PSE Pipeline

An automated daily pipeline that scrapes, processes, and visualizes public equity market data from all PSE listed companies.

## Background

This started as a personal project. After leaving a prop trading role, I lost access to tools I used daily which are expensive to maintain as an independent trader. I built this to replace those while keeping overhead cost zero. The original version was a manual Power BI dashboard. Functional, but fully manual. This is the proper rebuild: automated, cloud-hosted, and free to run. The DE Zoomcamp I am currently taking pushed me to finally build this properly. I did not follow the curriculum's promoted tools since I just wanted this to be straightforward and light. This project was a side quest that became a good implementation exercise.

## Architecture

<img alt="architecture" src=".docs/01 architecture v2.png" />

**Flow:** PSE EDGE → Scrapers → Supabase → DuckDB → Supabase → Power BI

**Schedule:** GitHub Actions cron, daily 2AM Philippine Time

## Lineage Graph

<img alt="architecture" src=".docs/07 dbt-dag.png" />

## Pipeline

### 1. Collect — `pse_pipeline_price.py` and `pse_pipeline_meta.py`

Two scrapers built with AI targeting [PSE EDGE](https://edge.pse.com.ph):

- **Price**:  OHLCV data for all 283 listed companies, incremental updates (only fetches from last known date)
- **Meta**:  Company info, stock data, and financial statements (balance sheet, income statement) scraped per company page

Both include rate limiting and error handling to survive partial failures.

Output: individual `.parquet` files per ticker → uploaded to `pse-price` and `pse-meta` Supabase buckets.

<img alt="input" src=".docs/02 input.png" />

### 2. Process — `pse_pipeline_dbt.py`

dbt Core with DuckDB adapter reads raw parquet files directly from Supabase via S3. Replaces the single-script CTE factory with 23 modular SQL models across three layers:
- Staging:  read raw parquet from S3, union all ticker files
- Intermediate:  clean and cast types, compute indicators at 3 timeframes (20/60/240 day), rolling highs/lows, breadth, alerts, normalize financials, FX conversion
- Mart:  aggregate to industry and sector level with profitability, valuation, and breadth rankings

Output: `pse_clean_price`, `pse_clean_meta`, `pse_clean_agg` as both `.parquet` and `.csv` → uploaded to `pse-clean` Supabase bucket (public).

<img alt="output price" src=".docs/05a output price df.png" />
<img alt="output meta" src=".docs/05b output meta df.png" />
<img alt="output agg" src=".docs/05c output agg df.png" />

### 3. Automate — GitHub Actions

All three scripts run sequentially in Docker containers. Supabase credentials are stored as GitHub Secrets.

<img alt="automation" src=".docs/03 automation v2.png" />

### 4. Visualize — Power BI

Power BI connects directly to the public Supabase CSV URLs. Dashboard auto-refreshes on each pipeline run.

<img alt="schema" src=".docs/06a schema relations.png" />
<img alt="overview" src=".docs/06b overview v2.png" />
<img alt="matrix" src=".docs/06c matrix v2.png" />
<img alt="trend" src=".docs/06d trend v2.png" />

## Stack

| Layer | Tool | Why |
|---|---|---|
| Scraping | AI + Python | PSE EDGE has no public API |
| Transformation | dbt Core + DuckDB | Modular SQL models, lineage graph, reads parquet directly via S3 |
| Storage | Supabase Storage | Free tier comfortably fits a 300-ticker dataset; public URL feeds Power BI directly |
| Orchestration | GitHub Actions | Sufficient for a single sequential job; no infrastructure to maintain |
| Packaging | Docker + uv | Reproducible environment, fast dependency installs |
| Visualization | Power BI | Auto-refresh via web URL |

## Decisions

**GitHub Actions over Kestra**:  Single sequential job, cron-triggered, free. Right tool for this scale.

**dbt over single Python script**:  Same SQL logic but modular. Each transformation is independently testable and visible in the lineage graph. Easier to debug and extend.

**DuckDB over Pandas**:  Reads Parquet directly from S3 without loading into memory. Transformation runs in-process, no database server needed.

**Parquet as storage format**:  Columnar, lightweight, works natively with DuckDB and most BI tools.
