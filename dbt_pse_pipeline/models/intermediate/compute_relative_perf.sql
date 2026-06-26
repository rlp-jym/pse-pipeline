WITH
all_time_values AS (

	SELECT *,
		MAX(High)	OVER w AS "All Time High",
		MIN(Low) 	OVER w AS "All Time Low",
		MAX(Chg) 	OVER w AS "All Time Chg High",
		MIN(Chg) 	OVER w AS "All Time Chg Low",
		MAX(Value)  OVER w AS "All Time Val High",
		MIN(Value)  OVER w AS "All Time Val Low",

	FROM  {{ ref('compute_breadth') }}
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	)
)

SELECT *,
	ROUND(((Close  / "Month High")      - 1) * 100, 2) AS "Relative Month High",
	ROUND(((Close  / "Month Low")       - 1) * 100, 2) AS "Relative Month Low",
	ROUND(((Close  / "Quarter High")    - 1) * 100, 2) AS "Relative Quarter High",
	ROUND(((Close  / "Quarter Low")     - 1) * 100, 2) AS "Relative Quarter Low",
	ROUND(((Close  / "Year High")       - 1) * 100, 2) AS "Relative Year High",
	ROUND(((Close  / "Year Low")        - 1) * 100, 2) AS "Relative Year Low",
	ROUND(((Close  / "All Time High")   - 1) * 100, 2) AS "Relative All Time High",
	ROUND(((Close  / "All Time Low")    - 1) * 100, 2) AS "Relative All Time Low",
	ROUND(((RSI20  / "Market RSI20")	- 1) * 100, 2) AS "Relative Market RSI 20",
	ROUND(((RSI60  / "Market RSI60") 	- 1) * 100, 2) AS "Relative Market RSI 60",
	ROUND(((RSI240 / "Market RSI240")   - 1) * 100, 2) AS "Relative Market RSI 240",
	ROUND(((RSI20  / "Sector RSI20")    - 1) * 100, 2) AS "Relative Sector RSI 20",
	ROUND(((RSI60  / "Sector RSI60")    - 1) * 100, 2) AS "Relative Sector RSI 60",
	ROUND(((RSI240 / "Sector RSI240")   - 1) * 100, 2) AS "Relative Sector RSI 240",
	ROUND(((RSI20  / "Industry RSI20")  - 1) * 100, 2) AS "Relative Industry RSI 20",
	ROUND(((RSI60  / "Industry RSI60")  - 1) * 100, 2) AS "Relative Industry RSI 60",
	ROUND(((RSI240 / "Industry RSI240") - 1) * 100, 2) AS "Relative Industry RSI 240"

FROM all_time_values