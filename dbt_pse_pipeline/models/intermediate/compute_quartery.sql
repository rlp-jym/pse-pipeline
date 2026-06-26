SELECT *,
	MAX(High)  OVER w AS "Quarter High",
	MIN(Low)   OVER w AS "Quarter Low",
	MAX(Chg)   OVER w AS "Quarter Chg High",
	MIN(Chg)   OVER w AS "Quarter Chg Low",
	MAX(Value) OVER w AS "Quarter Val High",
	MIN(Value) OVER w AS "Quarter Val Low",
	ROUND(AVG(Close) OVER w, 2) AS MA60,
	ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI60
FROM {{ ref('compute_monthy') }}
WINDOW w AS (
	PARTITION BY Symbol ORDER BY Date
	ROWS BETWEEN 59 PRECEDING AND CURRENT ROW ----------> simplify, just 20x3
)