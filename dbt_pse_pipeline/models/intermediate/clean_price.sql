WITH
tag AS (

	SELECT a.*,
		b."company_details.sector" AS Sector,
		clean_industry AS Industry,
		TRY_CAST((((close / LAG(close) OVER (PARTITION BY symbol ORDER BY date ASC)) - 1) * 100) AS DOUBLE) AS Chg

	FROM {{ ref('price') }} a
	JOIN {{ ref('meta') }} b ON a.symbol = b."company_info.symbol"

)

SELECT
	TRY_CAST(Date AS DATE) AS Date, 
	symbol AS Symbol, Sector, Industry, 
	TRY_CAST(Chg   AS NUMERIC) AS Chg,
	TRY_CAST(Open  AS NUMERIC) AS Open,
	TRY_CAST(High  AS NUMERIC) AS High,
	TRY_CAST(Low   AS NUMERIC) AS Low,
	TRY_CAST(Close AS NUMERIC) AS Close,
	TRY_CAST(CASE WHEN Chg > 0 THEN Chg      ELSE 0 END AS NUMERIC) AS Gain,
	TRY_CAST(CASE WHEN Chg < 0 THEN ABS(Chg) ELSE 0 END AS NUMERIC) AS Loss,
	TRY_CAST(Value AS BIGINT) AS Value,
	TRY_CAST(TRY_CAST(Value AS BIGINT) / TRY_CAST(Close AS DOUBLE) AS BIGINT) AS Volume

FROM tag
ORDER BY Date ASC