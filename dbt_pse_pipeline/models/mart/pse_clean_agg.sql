{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT *, 
	ROUND(("Profitability Rank" + 
	"Valuation Rank" + 
	"Breadth Rank") / 3, 2) AS "Overall Rank"
FROM {{ ref('compute_agg_ranks') }}
ORDER BY "Overall Rank" ASC