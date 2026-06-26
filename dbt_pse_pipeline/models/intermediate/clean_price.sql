WITH tag AS (
	SELECT a.*,
		b."company_details.sector" AS Sector,
		clean_industry AS Industry,
		TRY_CAST((((close / LAG(close) OVER (PARTITION BY symbol ORDER BY date ASC)) - 1) * 100) AS DOUBLE) AS Chg
	FROM {{ ref('stg_price') }} a
	JOIN {{ ref('stg_meta') }} b ON a.symbol = b."company_info.symbol"
)
SELECT
	TRY_CAST(Date AS DATE) AS Date, 
	symbol				   AS Symbol,
	Sector, Industry, 
	ROUND(TRY_CAST(Chg   AS DOUBLE), 2) AS Chg,
	ROUND(TRY_CAST(Open  AS DOUBLE), 2) AS Open,
	ROUND(TRY_CAST(High  AS DOUBLE), 2) AS High,
	ROUND(TRY_CAST(Low   AS DOUBLE), 2) AS Low,
	ROUND(TRY_CAST(Close AS DOUBLE), 2) AS Close,
	ROUND(TRY_CAST(CASE WHEN Chg > 0 THEN Chg      ELSE 0 END AS DOUBLE), 2) AS Gain,
	ROUND(TRY_CAST(CASE WHEN Chg < 0 THEN ABS(Chg) ELSE 0 END AS DOUBLE), 2) AS Loss,
	ROUND(TRY_CAST(Value AS BIGINT), 0)												    AS Value,
	ROUND(TRY_CAST(TRY_CAST(Value AS BIGINT) / TRY_CAST(Close AS DOUBLE) AS BIGINT), 0)	AS Volume
FROM tag
ORDER BY Date ASC
