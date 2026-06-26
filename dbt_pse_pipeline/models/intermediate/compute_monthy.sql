SELECT *,
	MAX(High)  OVER w AS "Month High",
	MIN(Low)   OVER w AS "Month Low",
	MAX(Chg)   OVER w AS "Month Chg High",
	MIN(Chg)   OVER w AS "Month Chg Low",
	MAX(Value) OVER w AS "Month Val High",
	MIN(Value) OVER w AS "Month Val Low",
	ROUND(AVG(Close) OVER w, 2) AS MA20,
	ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI20
FROM {{ ref('clean_price') }}
WINDOW w AS (
	PARTITION BY Symbol ORDER BY Date
	ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
)