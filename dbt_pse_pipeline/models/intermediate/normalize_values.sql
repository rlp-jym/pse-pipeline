WITH fx AS (

    SELECT
        MAX(CASE WHEN currency = 'usdphp' THEN rate END) AS usdphp,
        MAX(CASE WHEN currency = 'cadphp' THEN rate END) AS cadphp
    FROM {{ ref('fx_rates') }}
	
)

SELECT 
	"company_info.symbol"				  AS Symbol,
	"company_info.name"   				  AS Name,
	"company_details.company_description" AS Description,
	"company_details.sector" 			  AS Sector,
	clean_industry 						  AS Industry,
	"Market Cap",
	"Shares Out",
	"Float Pct",
	ROUND("Shares Out" * "Float Pct" / 100, 0) AS "Shares Float",

	TRY_CAST(strptime("financial_reports.annual_fiscal_year_ended", '%b %d, %Y') AS DATE) AS "Fiscal Year End",
	----- ANNUAL FX CONVERT
	CAST(CASE 
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%c$%'	 THEN (SELECT cadphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%$%' 	 THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%usd%' 	 THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%dollar%' THEN (SELECT usdphp FROM fx)
			ELSE 1 END AS DOUBLE) AS fx_year,
	CAST(CASE
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%mil%'  THEN 1000000
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%thou%' THEN 1000
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%000%'  THEN 1000
			ELSE 1 END AS DOUBLE) AS multiple_year,
	----- ANNUAL FINANCIAL STATEMENTS
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),

	TRY_CAST(strptime("financial_reports.quarterly_period_ended", '%b %d, %Y') AS DATE) AS "Fiscal Quarter End",
	----- QUARTERLY FX CONVERT
	CAST(CASE 
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%c$%'	    THEN (SELECT cadphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%$%'		THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%usd%' 	THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%dollar%' THEN (SELECT usdphp FROM fx)
			ELSE 1 END AS DOUBLE) AS fx_quarter,
	CAST(CASE
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%mil%'  THEN 1000000
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%thou%' THEN 1000
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%000%'  THEN 1000
			ELSE 1 END AS DOUBLE) AS multiple_quarter,
	----- QUARTERLY FINANCIAL STATEMENTS
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),        
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 3) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 4) AS DOUBLE),

	----- LAST PRICE AND INDICATOR VALUES
	Open, High, Low, Close, Chg, Gain, Loss, Value, Volume, MA20, RSI20, MA60, RSI60, MA240, RSI240, 
	"Month High",    "Month Low",    "Month Chg High",    "Month Chg Low",    "Month Val High",    "Month Val Low",
	"Quarter High",  "Quarter Low",  "Quarter Chg High",  "Quarter Chg Low",  "Quarter Val High",  "Quarter Val Low",
	"Year High",     "Year Low",     "Year Chg High",     "Year Chg Low",     "Year Val High",     "Year Val Low",
	"All Time High", "All Time Low", "All Time Chg High", "All Time Chg Low", "All Time Val High", "All Time Val Low", 
	"Market RSI20",   "Market RSI60",   "Market RSI240", 
	"Sector RSI20",   "Sector RSI60",   "Sector RSI240", 
	"Industry RSI20", "Industry RSI60", "Industry RSI240", 
	"Relative Month High",    "Relative Month Low",
	"Relative Quarter High",  "Relative Quarter Low",
	"Relative Year High",     "Relative Year Low", 
	"Relative All Time High", "Relative All Time Low",
	"Relative Market RSI 20",   "Relative Market RSI 60",   "Relative Market RSI 240",
	"Relative Sector RSI 20",   "Relative Sector RSI 60",   "Relative Sector RSI 240", 
	"Relative Industry RSI 20", "Relative Industry RSI 60", "Relative Industry RSI 240", 

FROM {{ ref('join_meta') }}