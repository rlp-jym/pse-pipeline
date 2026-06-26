WITH
compute_monthy AS (

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
	
),

compute_quarterly AS (

	SELECT *,
		MAX(High)  OVER w AS "Quarter High",
		MIN(Low)   OVER w AS "Quarter Low",
		MAX(Chg)   OVER w AS "Quarter Chg High",
		MIN(Chg)   OVER w AS "Quarter Chg Low",
		MAX(Value) OVER w AS "Quarter Val High",
		MIN(Value) OVER w AS "Quarter Val Low",
		ROUND(AVG(Close) OVER w, 2) AS MA60,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI60

	FROM compute_monthy
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 59 PRECEDING AND CURRENT ROW ----------> simplify, just 20x3
	)

),

compute_yearly AS (

	SELECT *,
		MAX(High)  OVER w AS "Year High",
		MIN(Low)   OVER w AS "Year Low",
		MAX(Chg)   OVER w AS "Year Chg High",
		MIN(Chg)   OVER w AS "Year Chg Low",
		MAX(Value) OVER w AS "Year Val High",
		MIN(Value) OVER w AS "Year Val Low",
		ROUND(AVG(Close) OVER w, 2) AS MA240,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI240

	FROM compute_quarterly
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 239 PRECEDING AND CURRENT ROW ----------> simplify, just 20x12
	)

)

SELECT * FROM compute_yearly