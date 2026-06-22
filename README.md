# PSE Pipeline

## Overview
Automated data pipeline from raw data to market intelligence dashboard.

## Architecture
<img width="1912" height="914" alt="github actions end to end" src="https://github.com/user-attachments/assets/f8f9ae88-ace0-4999-959d-094bae233090" />

## Pipeline Flow
1. Price scraper → pse-price bucket
2. Meta scraper → pse-meta bucket  
3. DuckDB processing → pse-clean bucket
4. Power BI dashboard

## Stack
- Collect: Python + requests + BeautifulSoup (scraping)
- Transform: DuckDB
- Automate: Docker + GitHub Actions
- Warehouse: Supabase
- Visualize: Power BI

## Data Source
PSE EDGE (edge.pse.com.ph)
283 listed companies, daily price updates

## Dashboard
[screenshots]
