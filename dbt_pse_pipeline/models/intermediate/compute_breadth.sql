SELECT *,
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date)          , 2) AS "Market RSI20",
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date)          , 2) AS "Market RSI60",
	ROUND(AVG(RSI240) OVER (PARTITION BY Date)          , 2) AS "Market RSI240",
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI20",
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI60",
	ROUND(AVG(RSI240) OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI240",
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI20",
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI60",
	ROUND(AVG(RSI240) OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI240"
FROM {{ ref('compute_yearly') }}