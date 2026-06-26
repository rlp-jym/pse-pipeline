WITH joined AS (
	SELECT *
	FROM {{ ref('stg_meta') }} a 
	LEFT JOIN {{ ref('extend_price_last_day') }} b ON a."company_info.symbol" = b.Symbol
)

SELECT * EXCLUDE (
	"stock_data.market_cap",
	"stock_data.outstanding_shares",
	"stock_data.free_float_percent"
),
ROUND(TRY_CAST(regexp_replace("stock_data.market_cap", ',', '', 'g')         AS DOUBLE), 0) AS "Market Cap",
ROUND(TRY_CAST(regexp_replace("stock_data.outstanding_shares", ',', '', 'g') AS DOUBLE), 0) AS "Shares Out",
ROUND(TRY_CAST(regexp_replace("stock_data.free_float_percent", '%', '')      AS DOUBLE), 2) AS "Float Pct"
FROM joined