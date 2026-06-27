WITH 
ttm AS (

	SELECT *,
		"CY Revenue" - "PY YTD Revenue" + "CY YTD Revenue" AS "TTM Revenue",
		"CY Income"  - "PY YTD Income"  + "CY YTD Income"  AS "TTM Income",
		"CY EPS"     - "PY YTD EPS"     + "CY YTD EPS"     AS "TTM EPS"

	FROM {{ ref('improve_tags') }}

)

SELECT *,
	----- GROWTH AND PROFITABILITY
	ROUND((("TTM Revenue" - "CY Revenue") / ABS(NULLIF("CY Revenue", 0))) * 100, 2) AS "Revenue Growth",
	ROUND((("TTM Income"  - "CY Income")  / ABS(NULLIF("CY Income" , 0))) * 100, 2) AS "Income Growth",
	ROUND((("TTM EPS"     - "CY EPS")     / ABS(NULLIF("CY EPS"    , 0))) * 100, 2) AS "EPS Growth",
	ROUND("TTM Income" / NULLIF("TTM Revenue"                 , 0) * 100, 2) AS "Income Margin",
	ROUND("TTM Income" / NULLIF("CQ Total Assets", 0) * 100, 2) AS "Return On Assets",
	ROUND("TTM Income" / NULLIF("CQ Equity"      , 0) * 100, 2) AS "Return On Equity",
	----- LIQUIDITY AND SOLVENCY
	ROUND("CQ Current Assets"    / NULLIF("CQ Current Liabilities", 0), 2) AS "Current Ratio",
	ROUND("CQ Total Liabilities" / NULLIF("CQ Total Assets"       , 0), 2) AS "Debt Ratio",     ----------> proxy: total debt not available
	ROUND("CQ Total Liabilities" / NULLIF("CQ Equity"             , 0), 2) AS "D/E Ratio",      ----------> proxy: total debt not available
	----- VALUATION
	ROUND("Market Cap"  / NULLIF("TTM Revenue", 0), 2) AS "P/S",
	ROUND("Market Cap"  / NULLIF("TTM Income" , 0), 2) AS "P/E",
	ROUND(("Market Cap" / NULLIF("TTM Revenue", 0)) / ((("TTM Revenue" - "CY Revenue") / ABS(NULLIF("CY Revenue", 0))) * 100), 2) AS "PS/G",
	ROUND(("Market Cap" / NULLIF("TTM Income" , 0)) / ((("TTM Income"  - "CY Income")  / ABS(NULLIF("CY Income" , 0))) * 100), 2) AS "PE/G",
	ROUND("Market Cap"  / NULLIF("CQ Equity", 0), 2) AS "P/BV Ratio"

FROM ttm