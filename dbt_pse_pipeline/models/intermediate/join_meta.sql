WITH
joined AS (

	SELECT *
	FROM {{ ref('meta') }} a 
	LEFT JOIN {{ ref('pse_clean_price_last_day') }} b
		ON a."company_info.symbol" = b.Symbol

)

SELECT * EXCLUDE (
		"stock_data.market_cap",
		"stock_data.outstanding_shares",
		"stock_data.free_float_percent"
	),
	ROUND(TRY_CAST(regexp_replace("stock_data.market_cap", ',', '', 'g')         AS BIGINT),  0) AS MarketCap,
	ROUND(TRY_CAST(regexp_replace("stock_data.outstanding_shares", ',', '', 'g') AS BIGINT),  0) AS SharesOut,
	ROUND(TRY_CAST(regexp_replace("stock_data.free_float_percent", '%', '')      AS NUMERIC), 2) AS FloatPct

FROM joined