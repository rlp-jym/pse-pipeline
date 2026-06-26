SELECT *,
	MAX(High)  OVER w AS "Year High",
	MIN(Low)   OVER w AS "Year Low",
	MAX(Chg)   OVER w AS "Year Chg High",
	MIN(Chg)   OVER w AS "Year Chg Low",
	MAX(Value) OVER w AS "Year Val High",
	MIN(Value) OVER w AS "Year Val Low",
	ROUND(AVG(Close) OVER w, 2) AS MA240,
	ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI240
FROM {{ ref('compute_quartery') }}
WINDOW w AS (
	PARTITION BY Symbol ORDER BY Date
	ROWS BETWEEN 239 PRECEDING AND CURRENT ROW ----------> simplify, just 20x12
)