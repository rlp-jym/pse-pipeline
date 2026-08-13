WITH
all_time_values AS (

	SELECT *,
		MAX(High) OVER w AS HighAll,
		MIN(Low)  OVER w AS LowAll,

	FROM  {{ ref('compute_breadth') }}
	WINDOW w AS (
		PARTITION BY Symbol ORDER BY Date
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	)
)

SELECT *,
	--------------------------------------------------
	ROUND(((Close / High5)   - 1) * 100, 2) AS RelativeHigh5,
	ROUND(((Close / High10)  - 1) * 100, 2) AS RelativeHigh10,
	ROUND(((Close / High20)  - 1) * 100, 2) AS RelativeHigh20,
	ROUND(((Close / High30)  - 1) * 100, 2) AS RelativeHigh30,
	ROUND(((Close / High60)  - 1) * 100, 2) AS RelativeHigh60,
	ROUND(((Close / High120) - 1) * 100, 2) AS RelativeHigh120,
	ROUND(((Close / High240) - 1) * 100, 2) AS RelativeHigh240,
	ROUND(((Close / HighAll) - 1) * 100, 2) AS RelativeHighAll,
	--------------------------------------------------
	ROUND(((Close / Low5)    - 1) * 100, 2) AS RelativeLow5,
	ROUND(((Close / Low10)   - 1) * 100, 2) AS RelativeLow10,
	ROUND(((Close / Low20)   - 1) * 100, 2) AS RelativeLow20,
	ROUND(((Close / Low30)   - 1) * 100, 2) AS RelativeLow30,
	ROUND(((Close / Low60)   - 1) * 100, 2) AS RelativeLow60,
	ROUND(((Close / Low120)  - 1) * 100, 2) AS RelativeLow120,
	ROUND(((Close / Low240)  - 1) * 100, 2) AS RelativeLow240,
	ROUND(((Close / LowAll)  - 1) * 100, 2) AS RelativeLowAll,
	--------------------------------------------------
	ROUND(((RSI5   / MarketRSI5)   - 1) * 100, 2) AS RelativeMarketRSI5,
	ROUND(((RSI10  / MarketRSI10)  - 1) * 100, 2) AS RelativeMarketRSI10,
	ROUND(((RSI20  / MarketRSI20)  - 1) * 100, 2) AS RelativeMarketRSI20,
	ROUND(((RSI30  / MarketRSI30)  - 1) * 100, 2) AS RelativeMarketRSI30,
	ROUND(((RSI60  / MarketRSI60)  - 1) * 100, 2) AS RelativeMarketRSI60,
	ROUND(((RSI120 / MarketRSI120) - 1) * 100, 2) AS RelativeMarketRSI120,
	ROUND(((RSI240 / MarketRSI240) - 1) * 100, 2) AS RelativeMarketRSI240,
	--------------------------------------------------
	ROUND(((RSI5   / SectorRSI5)   - 1) * 100, 2) AS RelativeSectorRSI5,
	ROUND(((RSI10  / SectorRSI10)  - 1) * 100, 2) AS RelativeSectorRSI10,
	ROUND(((RSI20  / SectorRSI20)  - 1) * 100, 2) AS RelativeSectorRSI20,
	ROUND(((RSI30  / SectorRSI30)  - 1) * 100, 2) AS RelativeSectorRSI30,
	ROUND(((RSI60  / SectorRSI60)  - 1) * 100, 2) AS RelativeSectorRSI60,
	ROUND(((RSI120 / SectorRSI120) - 1) * 100, 2) AS RelativeSectorRSI120,
	ROUND(((RSI240 / SectorRSI240) - 1) * 100, 2) AS RelativeSectorRSI240,
	--------------------------------------------------
	ROUND(((RSI5   / IndustryRSI5)   - 1) * 100, 2) AS RelativeIndustryRSI5,
	ROUND(((RSI10  / IndustryRSI10)  - 1) * 100, 2) AS RelativeIndustryRSI10,
	ROUND(((RSI20  / IndustryRSI20)  - 1) * 100, 2) AS RelativeIndustryRSI20,
	ROUND(((RSI30  / IndustryRSI30)  - 1) * 100, 2) AS RelativeIndustryRSI30,
	ROUND(((RSI60  / IndustryRSI60)  - 1) * 100, 2) AS RelativeIndustryRSI60,
	ROUND(((RSI120 / IndustryRSI120) - 1) * 100, 2) AS RelativeIndustryRSI120,
	ROUND(((RSI240 / IndustryRSI240) - 1) * 100, 2) AS RelativeIndustryRSI240

FROM all_time_values