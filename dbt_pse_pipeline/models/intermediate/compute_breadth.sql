SELECT *,
	--------------------------------------------------
	ROUND(AVG(RSI5)   OVER (PARTITION BY Date)          , 2) AS MarketRSI5,
	ROUND(AVG(RSI10)  OVER (PARTITION BY Date)          , 2) AS MarketRSI10,
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date)          , 2) AS MarketRSI20,
	ROUND(AVG(RSI30)  OVER (PARTITION BY Date)          , 2) AS MarketRSI30,
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date)          , 2) AS MarketRSI60,
	ROUND(AVG(RSI240) OVER (PARTITION BY Date)          , 2) AS MarketRSI240,
	--------------------------------------------------
	ROUND(AVG(RSI5)   OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI5,
	ROUND(AVG(RSI10)  OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI10,
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI20,
	ROUND(AVG(RSI30)  OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI30,
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI60,
	ROUND(AVG(RSI240) OVER (PARTITION BY Date, Sector)  , 2) AS SectorRSI240,
	--------------------------------------------------
	ROUND(AVG(RSI5)   OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI5,
	ROUND(AVG(RSI10)  OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI10,
	ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI20,
	ROUND(AVG(RSI30)  OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI30,
	ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI60,
	ROUND(AVG(RSI240) OVER (PARTITION BY Date, Industry), 2) AS IndustryRSI240

FROM {{ ref('compute_indicators') }}