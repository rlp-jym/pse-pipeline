SELECT *,
	MAX(High)	OVER w AS "All Time High",
	MIN(Low) 	OVER w AS "All Time Low",
	MAX(Chg) 	OVER w AS "All Time Chg High",
	MIN(Chg) 	OVER w AS "All Time Chg Low",
	MAX(Value)  OVER w AS "All Time Val High",
	MIN(Value)  OVER w AS "All Time Val Low",
	MAX(RSI20)  OVER w AS "All Time RSI20 High",
	MIN(RSI20)  OVER w AS "All Time RSI20 Low",
	MAX(RSI60)  OVER w AS "All Time RSI60 High",
	MIN(RSI60)  OVER w AS "All Time RSI60 Low",
	MAX(RSI240) OVER w AS "All Time RSI240 High",
	MIN(RSI240) OVER w AS "All Time RSI240 Low"
FROM {{ ref('compute_relative_perf') }}
WINDOW w AS (
	PARTITION BY Symbol ORDER BY Date
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)