# PSE Pipeline

## Overview
A decentralized data pipeline that automates the daily extraction, transformation, and visualization of public equity market data from the PSE EDGE platform.  

## Architecture
<img width="1912" height="914" alt="github actions end to end" src=".docs/01 architecture.png" />

## Pipeline Flow
1. Collect - Python Gathering Scripts
2. Store - Supabase Cloud Storage
3. Process - DuckDB CTE Factory Script
4. Visualize - Power BI
5. Automate - GitHub Actions

## Automation
<img width="1912" height="914" alt="github actions end to end" src=".docs/03 automation.png" />

## Transformation
Input
<img width="1912" height="914" alt="github actions end to end" src=".docs/02 input.png" />

Output
<img width="1912" height="914" alt="github actions end to end" src=".docs/05a output price df.png" />
<img width="1912" height="914" alt="github actions end to end" src=".docs/05b output meta df.png" />
<img width="1912" height="914" alt="github actions end to end" src=".docs/05c output agg df.png" />

## Dashboard
<img width="1912" height="914" alt="github actions end to end" src=".docs/06a sample dashboard.png" />
<img width="1912" height="914" alt="github actions end to end" src=".docs/06b sample dashboard.png" />
