{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT *,
	CASE
		WHEN High == "All Time High" THEN 'All Time High'
		WHEN High == "Year High"     THEN 'Year High'
		WHEN High == "Quarter High"  THEN 'Quarter High'
			ELSE '' END AS "Breakout Alert",
	CASE
		WHEN Low == "All Time Low" THEN 'All Time Low'
		WHEN Low == "Year Low"     THEN 'Year Low'
		WHEN Low == "Quarter Low"  THEN 'Quarter Low'
			ELSE '' END AS "Breakdown Alert",
	CASE
		WHEN RSI20 < 10 THEN 'Panic'
		WHEN RSI20 < 20 THEN 'Oversold'
		WHEN RSI20 > 90 THEN 'Euphoric'
		WHEN RSI20 > 80 THEN 'Overbought'
			ELSE '' END AS "Behavioral Alert"
FROM {{ ref('compute_ratios') }}
ORDER BY "Market Cap" DESC