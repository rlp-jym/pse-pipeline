WITH
ratios AS (

	SELECT * EXCLUDE (RevenueBase, IncomeBase), 
		ROUND(((Revenue / NULLIF(RevenueBase, 0)) - 1) * 100, 2) AS GrowthRevenue,
		ROUND(((Income  / NULLIF(IncomeBase,  0)) - 1) * 100, 2) AS GrowthIncome,
		ROUND(Income    / NULLIF(Revenue, 0) * 100, 2) AS MarginIncome, 
		ROUND(Income    / NULLIF(Assets , 0) * 100, 2) AS ReturnOnAssets, 
		ROUND(Income    / NULLIF(Equity , 0) * 100, 2) AS ReturnOnEquity, 
		ROUND(MarketCap / NULLIF(Revenue, 0), 2) AS PSRatio, 
		ROUND(MarketCap / NULLIF(Income , 0), 2) AS PERatio, 
		ROUND(MarketCap / NULLIF(Equity , 0), 2) AS PBVRatio
		
	 FROM {{ ref('union_agg') }}
	 
)

SELECT *,
	ROUND(PSRatio / NULLIF(GrowthRevenue, 0), 2) AS PSGRatio,
	ROUND(PERatio / NULLIF(GrowthIncome , 0), 2) AS PEGRatio
	
FROM ratios