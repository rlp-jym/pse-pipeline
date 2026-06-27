WITH
ratios AS (

	SELECT * EXCLUDE ("CY Revenue", "CY Income"), 
		ROUND(((Revenue / NULLIF("CY Revenue", 0)) - 1) * 100, 2) AS "Revenue Growth",
		ROUND(((Income  / NULLIF("CY Income" , 0)) - 1) * 100, 2) AS "Income Growth",
		ROUND(Income    / NULLIF(Revenue, 0) * 100, 2) AS "Income Margin", 
		ROUND(Income    / NULLIF(Assets , 0) * 100, 2) AS "Return On Assets", 
		ROUND(Income    / NULLIF(Equity , 0) * 100, 2) AS "Return On Equity", 
		ROUND("Market Cap" / NULLIF(Revenue, 0), 2) AS "P/S", 
		ROUND("Market Cap" / NULLIF(Income , 0), 2) AS "P/E", 
		ROUND("Market Cap" / NULLIF(Equity , 0), 2) AS "P/BV"
		
	 FROM {{ ref('union_agg') }}
	 
)

SELECT *,
	ROUND("P/S" / NULLIF("Revenue Growth", 0), 2) AS "PS/G",
	ROUND("P/E" / NULLIF("Income Growth" , 0), 2) AS "PE/G"
	
FROM ratios