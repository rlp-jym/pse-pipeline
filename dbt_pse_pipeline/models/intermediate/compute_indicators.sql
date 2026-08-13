WITH
compute5 AS (

	SELECT *,
		MAX(High)  OVER w AS High5,
		MIN(Low)   OVER w AS Low5,
		ROUND(AVG(Close) OVER w, 2) AS MA5,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI5

	FROM {{ ref('clean_price') }}
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
	)
	
),

compute10 AS (

	SELECT *,
		MAX(High)  OVER w AS High10,
		MIN(Low)   OVER w AS Low10,
		ROUND(AVG(Close) OVER w, 2) AS MA10,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI10

	FROM compute5
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
	)
	
),

compute20 AS (

	SELECT *,
		MAX(High)  OVER w AS High20,
		MIN(Low)   OVER w AS Low20,
		ROUND(AVG(Close) OVER w, 2) AS MA20,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI20

	FROM compute10
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
	)
	
),

compute30 AS (

	SELECT *,
		MAX(High)  OVER w AS High30,
		MIN(Low)   OVER w AS Low30,
		ROUND(AVG(Close) OVER w, 2) AS MA30,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI30

	FROM compute20
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 29 PRECEDING AND CURRENT ROW ----------> simplify, just 20x3
	)

),

compute60 AS (

	SELECT *,
		MAX(High)  OVER w AS High60,
		MIN(Low)   OVER w AS Low60,
		ROUND(AVG(Close) OVER w, 2) AS MA60,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI60

	FROM compute30
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 59 PRECEDING AND CURRENT ROW ----------> simplify, just 20x3
	)

),

compute120 AS (

	SELECT *,
		MAX(High)  OVER w AS High120,
		MIN(Low)   OVER w AS Low120,
		ROUND(AVG(Close) OVER w, 2) AS MA120,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI120

	FROM compute60
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 119 PRECEDING AND CURRENT ROW ----------> simplify, just 20x12
	)

),

compute240 AS (

	SELECT *,
		MAX(High)  OVER w AS High240,
		MIN(Low)   OVER w AS Low240,
		ROUND(AVG(Close) OVER w, 2) AS MA240,
		ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS NUMERIC), 2) AS RSI240

	FROM compute120
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN 239 PRECEDING AND CURRENT ROW ----------> simplify, just 20x12
	)

)

SELECT * FROM compute240