WITH 
pre_rank AS (

	SELECT *,
		----- PROFITABILITY RANKINGS, HIGHER IS BETTER
		DENSE_RANK() OVER (ORDER BY "Revenue Growth"   DESC) AS "Revenue Growth Rank",
		DENSE_RANK() OVER (ORDER BY "Income Growth"    DESC) AS "Income Growth Rank",
		DENSE_RANK() OVER (ORDER BY "Income Margin"    DESC) AS "Margin Rank",
		DENSE_RANK() OVER (ORDER BY "Return on Assets" DESC) AS "ROA Rank",
		DENSE_RANK() OVER (ORDER BY "Return on Equity" DESC) AS "ROE Rank",
		----- VALUATION RANKINGS, LOWER IS BETTER
		DENSE_RANK() OVER (ORDER BY "P/S"  ASC) AS "PS Rank",
		DENSE_RANK() OVER (ORDER BY "P/E"  ASC) AS "PE Rank",
		DENSE_RANK() OVER (ORDER BY "P/BV" ASC) AS "PBV Rank",  
		----- BREADTH RANKINGS, HIGHER IS BETTER
		DENSE_RANK() OVER (ORDER BY "MA20 Breadth"  DESC) AS "ST Breadth Rank",
		DENSE_RANK() OVER (ORDER BY "MA60 Breadth"  DESC) AS "MT Breadth Rank",
		DENSE_RANK() OVER (ORDER BY "MA240 Breadth" DESC) AS "LT Breadth Rank"
		
	FROM {{ ref('compute_agg_ratios') }}
	
)

SELECT *,
	ROUND((
		"Revenue Growth Rank" +
		"Income Growth Rank" +
		"Margin Rank" +
		"ROA Rank" +
		"ROE Rank") / 5, 2) AS "Profitability Rank",
	ROUND((
		"PS Rank" +
		"PE Rank" +
		"PBV Rank") / 3, 2) AS "Valuation Rank",
	ROUND((
		"ST Breadth Rank" +
		"MT Breadth Rank" +
		"LT Breadth Rank") / 3, 2) AS "Breadth Rank"
		
FROM pre_rank