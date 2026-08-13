WITH 
pre_rank AS (

	SELECT *,
		----- PROFITABILITY RANKINGS, HIGHER IS BETTER
		DENSE_RANK() OVER (ORDER BY GrowthRevenue  DESC) AS RankGrowthRevenue,
		DENSE_RANK() OVER (ORDER BY GrowthIncome   DESC) AS RankGrowthIncome,
		DENSE_RANK() OVER (ORDER BY MarginIncome   DESC) AS RankMargin,
		DENSE_RANK() OVER (ORDER BY ReturnOnAssets DESC) AS RankROA,
		DENSE_RANK() OVER (ORDER BY ReturnOnEquity DESC) AS RankROE,
		----- VALUATION RANKINGS, HIGHER IS BETTER
		DENSE_RANK() OVER (ORDER BY PSRatio  DESC) AS RankPSRatio,
		DENSE_RANK() OVER (ORDER BY PERatio  DESC) AS RankPERatio,
		DENSE_RANK() OVER (ORDER BY PBVRatio DESC) AS RankPBVRatio,  
		----- BREADTH RANKINGS, HIGHER IS BETTER
		DENSE_RANK() OVER (ORDER BY BreadthMA5   DESC) AS RankBreadth5,
		DENSE_RANK() OVER (ORDER BY BreadthMA10  DESC) AS RankBreadth10,
		DENSE_RANK() OVER (ORDER BY BreadthMA20  DESC) AS RankBreadth20,
		DENSE_RANK() OVER (ORDER BY BreadthMA30  DESC) AS RankBreadth30,
		DENSE_RANK() OVER (ORDER BY BreadthMA60  DESC) AS RankBreadth60,
		DENSE_RANK() OVER (ORDER BY BreadthMA120 DESC) AS RankBreadth120,
		DENSE_RANK() OVER (ORDER BY BreadthMA240 DESC) AS RankBreadth240
		
	FROM {{ ref('compute_agg_ratios') }}
	
)

SELECT *,
	ROUND((
		RankGrowthRevenue + RankGrowthIncome +
		RankMargin + RankROA + RankROE)
		/ 5, 2) AS RankProfitability,
	ROUND((
		RankPSRatio + RankPERatio + RankPBVRatio)
		/ 3, 2) AS RankValuation,
	ROUND((
		RankBreadth20 + RankBreadth60 + RankBreadth240)
		/ 3, 2) AS RankBreadth
		
FROM pre_rank