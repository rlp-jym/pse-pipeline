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
	MarketCap, SharesOut, FloatPct,
	ROUND(SharesOut * FloatPct / 100, 0)  AS SharesFloat,
	--------------------------------------------------
	TRY_CAST(strptime("financial_reports.annual_fiscal_year_ended", '%b %d, %Y') AS DATE) AS FiscalYearEnd,
	----- ANNUAL FX CONVERT
	CAST(CASE 
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%c$%'	 THEN (SELECT cadphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%$%' 	 THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%usd%' 	 THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%dollar%' THEN (SELECT usdphp FROM fx)
			ELSE 1 END AS NUMERIC) AS fxYear,
	CAST(CASE
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%mil%'  THEN 1000000
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%thou%' THEN 1000
		WHEN LOWER("financial_reports.annual_currency") ILIKE '%000%'  THEN 1000
			ELSE 1 END AS NUMERIC) AS multipleYear,
	----- ANNUAL FINANCIAL STATEMENTS
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),
	--------------------------------------------------
	TRY_CAST(strptime("financial_reports.quarterly_period_ended", '%b %d, %Y') AS DATE) AS FiscalQuarterEnd,
	----- QUARTERLY FX CONVERT
	CAST(CASE 
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%c$%'	    THEN (SELECT cadphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%$%'		THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%usd%' 	THEN (SELECT usdphp FROM fx)
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%dollar%' THEN (SELECT usdphp FROM fx)
			ELSE 1 END AS NUMERIC) AS fxQuarter,
	CAST(CASE
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%mil%'  THEN 1000000
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%thou%' THEN 1000
		WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%000%'  THEN 1000
			ELSE 1 END AS NUMERIC) AS multipleQuarter,
	----- QUARTERLY FINANCIAL STATEMENTS
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 1) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 2) AS DOUBLE),        
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 3) AS DOUBLE),
	TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\"\,\[\]]', '', 'g'), ' ', 4) AS DOUBLE),
	--------------------------------------------------
	----- LAST PRICE AND INDICATOR VALUES
	Open, High, Low, Close, Chg, Gain, Loss, Value, Volume,
	MA5, MA10, MA20, MA30, MA60, MA120, MA240, 
	RSI5, RSI10, RSI20, RSI30, RSI60, RSI120, RSI240, 
	High5, High10, High20, High30, High60, High120, High240, HighAll, 
	Low5, Low10, Low20, Low30, Low60, Low120, Low240, LowAll, 
	MarketRSI5, MarketRSI10, MarketRSI20, MarketRSI30, MarketRSI60, MarketRSI120, MarketRSI240, 
	SectorRSI5, SectorRSI10, SectorRSI20, SectorRSI30, SectorRSI60, SectorRSI120, SectorRSI240, 
	IndustryRSI5, IndustryRSI10, IndustryRSI20, IndustryRSI30, IndustryRSI60, IndustryRSI120, IndustryRSI240, 
	RelativeHigh5, RelativeHigh10, RelativeHigh20, RelativeHigh30, RelativeHigh60, RelativeHigh120, RelativeHigh240, RelativeHighAll, 
	RelativeLow5, RelativeLow10, RelativeLow20, RelativeLow30, RelativeLow60, RelativeLow120, RelativeLow240, RelativeLowAll, 
	RelativeVolatility5, RelativeVolatility20, RelativeVolatility60, RelativeVolatility240,
	RelativeMarketRSI5, RelativeMarketRSI10, RelativeMarketRSI20, RelativeMarketRSI30, RelativeMarketRSI60, RelativeMarketRSI120, RelativeMarketRSI240, 
	RelativeSectorRSI5, RelativeSectorRSI10, RelativeSectorRSI20, RelativeSectorRSI30, RelativeSectorRSI60, RelativeSectorRSI120, RelativeSectorRSI240, 
	RelativeIndustryRSI5, RelativeIndustryRSI10, RelativeIndustryRSI20, RelativeIndustryRSI30, RelativeIndustryRSI60, RelativeIndustryRSI120, RelativeIndustryRSI240, 

FROM {{ ref('join_meta') }}