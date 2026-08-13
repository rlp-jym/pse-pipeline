SELECT
	Sector,
	Industry, 
	COUNT(*) AS Count,
	ROUND(CAST(SUM(Value)              AS BIGINT),  0) AS Turnover,
	ROUND(CAST(SUM(MarketCap)          AS BIGINT),  0) AS MarketCap,
	ROUND(CAST(SUM(CQAssetsTotal)      AS BIGINT),  0) AS Assets,
	ROUND(CAST(SUM(CQLiabilitiesTotal) AS BIGINT),  0) AS Liabilities,
	ROUND(CAST(SUM(CQEquity)           AS BIGINT),  0) AS Equity,
	ROUND(CAST(SUM(TTMRevenue)         AS BIGINT),  0) AS Revenue,
	ROUND(CAST(SUM(TTMIncome)          AS BIGINT),  0) AS Income,
	ROUND(CAST(SUM(CYRevenue)          AS BIGINT),  0) AS RevenueBase,
	ROUND(CAST(SUM(CYIncome)           AS BIGINT),  0) AS IncomeBase,
	--------------------------------------------------
	ROUND(CAST(AVG(RSI5)               AS NUMERIC), 2) AS AvgRSI5,
	ROUND(CAST(AVG(RSI10)              AS NUMERIC), 2) AS AvgRSI10,
	ROUND(CAST(AVG(RSI20)              AS NUMERIC), 2) AS AvgRSI20,
	ROUND(CAST(AVG(RSI30)              AS NUMERIC), 2) AS AvgRSI30,
	ROUND(CAST(AVG(RSI60)              AS NUMERIC), 2) AS AvgRSI60,
	ROUND(CAST(AVG(RSI240)             AS NUMERIC), 2) AS AvgRSI240,
	--------------------------------------------------
	ROUND((COUNT(*) FILTER (WHERE Close > MA5)   / COUNT(*) * 100), 2) AS BreadthMA5,
	ROUND((COUNT(*) FILTER (WHERE Close > MA10)  / COUNT(*) * 100), 2) AS BreadthMA10,
	ROUND((COUNT(*) FILTER (WHERE Close > MA20)  / COUNT(*) * 100), 2) AS BreadthMA20,
	ROUND((COUNT(*) FILTER (WHERE Close > MA30)  / COUNT(*) * 100), 2) AS BreadthMA30,
	ROUND((COUNT(*) FILTER (WHERE Close > MA60)  / COUNT(*) * 100), 2) AS BreadthMA60,
	ROUND((COUNT(*) FILTER (WHERE Close > MA240) / COUNT(*) * 100), 2) AS BreadthMA240,
	
FROM {{ ref('pse_clean_meta') }}
WHERE Sector != 'ETF'
GROUP BY Sector, Industry



