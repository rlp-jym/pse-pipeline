{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT *, 
	ROUND((
		RankProfitability + 
		RankValuation + 
		RankBreadth)
			/ 3, 2) AS RankOverall
FROM {{ ref('compute_agg_ranks') }}
ORDER BY RankOverall ASC