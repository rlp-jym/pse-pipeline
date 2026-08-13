WITH 
ttm AS (

	SELECT *,
		CYRevenue - PYytdRevenue + CYytdRevenue AS TTMRevenue,
		CYIncome  - PYytdIncome  + CYytdIncome  AS TTMIncome,
		CYEPS     - PYytdEPS     + CYytdEPS     AS TTMEPS

	FROM {{ ref('improve_tags') }}

)

SELECT *,
	----- GROWTH AND PROFITABILITY
	ROUND(((TTMRevenue - CYRevenue) / ABS(NULLIF(CYRevenue, 0))) * 100, 2) AS GrowthRevenue,
	ROUND(((TTMIncome  - CYIncome)  / ABS(NULLIF(CYIncome , 0))) * 100, 2) AS GrowthIncome,
	ROUND(((TTMEPS     - CYEPS)     / ABS(NULLIF(CYEPS    , 0))) * 100, 2) AS GrowthEPS,
	ROUND(TTMIncome / NULLIF(TTMRevenue   , 0) * 100, 2) AS MarginIncome,
	ROUND(TTMIncome / NULLIF(CQAssetsTotal, 0) * 100, 2) AS ReturnOnAssets,
	ROUND(TTMIncome / NULLIF(CQEquity     , 0) * 100, 2) AS ReturnOnEquity,
	----- LIQUIDITY AND SOLVENCY
	ROUND(CQAssetsCurrent    / NULLIF(CQLiabilitiesCurrent, 0), 2) AS CurrentRatio,
	ROUND(CQLiabilitiesTotal / NULLIF(CQAssetsTotal       , 0), 2) AS LiabilitiesAssetsRatio,       ----------> proxy: total debt not available
	ROUND(CQLiabilitiesTotal / NULLIF(CQEquity            , 0), 2) AS LiabilitiesEquityRatio, ----------> proxy: total debt not available
	----- VALUATION
	ROUND(MarketCap  / NULLIF(TTMRevenue, 0), 2) AS PSRatio,
	ROUND(MarketCap  / NULLIF(TTMIncome , 0), 2) AS PERatio,
	ROUND(MarketCap  / NULLIF(CQEquity  , 0), 2) AS PBVRatio,
	ROUND((MarketCap / NULLIF(TTMRevenue, 0)) / (((TTMRevenue - CYRevenue) / ABS(NULLIF(CYRevenue, 0))) * 100), 2) AS PSGRatio,
	ROUND((MarketCap / NULLIF(TTMIncome , 0)) / (((TTMIncome  - CYIncome)  / ABS(NULLIF(CYIncome , 0))) * 100), 2) AS PEGRatio

FROM ttm