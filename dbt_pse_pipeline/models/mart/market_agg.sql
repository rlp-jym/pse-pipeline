SELECT 'Total Market' AS Sector, 'Total Market' AS Industry, 
	COUNT(*) AS Count,
	ROUND(CAST(SUM("Value")                AS BIGINT), 0) AS Turnover,
	ROUND(CAST(SUM("Market Cap")           AS BIGINT), 0) AS "Market Cap",
	ROUND(CAST(SUM("CQ Total Assets")      AS BIGINT), 0) AS Assets,
	ROUND(CAST(SUM("CQ Total Liabilities") AS BIGINT), 0) AS Liabilities,
	ROUND(CAST(SUM("CQ Equity")            AS BIGINT), 0) AS Equity,
	ROUND(CAST(SUM("TTM Revenue")          AS BIGINT), 0) AS Revenue,
	ROUND(CAST(SUM("TTM Income")           AS BIGINT), 0) AS Income,
	ROUND(CAST(AVG("RSI20")                AS DOUBLE), 0) AS RSI20,
	ROUND(CAST(AVG("RSI60")                AS DOUBLE), 0) AS RSI60,
	ROUND(CAST(AVG("RSI240")               AS DOUBLE), 0) AS RSI240,
	ROUND((COUNT(*) FILTER (WHERE Close > MA20) / COUNT(*) * 100), 2)  AS "MA20 Breadth",
	ROUND((COUNT(*) FILTER (WHERE Close > MA60) / COUNT(*) * 100), 2)  AS "MA60 Breadth",
	ROUND((COUNT(*) FILTER (WHERE Close > MA240) / COUNT(*) * 100), 2) AS "MA240 Breadth",
	SUM("CY Revenue") AS "CY Revenue",
	SUM("CY Income")  AS "CY Income"
FROM {{ ref('pse_clean_meta') }}
WHERE Sector != 'ETF'