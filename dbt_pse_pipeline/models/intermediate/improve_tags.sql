SELECT
	Symbol, Name, Description, Sector, Industry, MarketCap, SharesOut, SharesFloat, FloatPct,
	--------------------------------------------------
	FiscalYearEnd,
	----- BALANCE SHEET, CURRENT YEAR
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Current Assets"                AS BIGINT), 0) AS CYAssetsCurrent,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Total Assets"                  AS BIGINT), 0) AS CYAssetsTotal,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Current Liabilities"           AS BIGINT), 0) AS CYLiabilitiesCurrent,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Total Liabilities"             AS BIGINT), 0) AS CYLiabilitiesTotal,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Retained Earnings/(Deficit)"   AS BIGINT), 0) AS CYRetainedEarnings,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Stockholders' Equity"          AS BIGINT), 0) AS CYEquity,
	ROUND(fxYear * "financial_reports.annual_balance_sheet.Book Value Per Share"                                        , 2) AS CYBVPS,
	----- BALANCE SHEET, PREVIOUS YEAR
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Current Assets_1"              AS BIGINT), 0) AS PYAssetsCurrent,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Total Assets_1"                AS BIGINT), 0) AS PYAssetsTotal,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Current Liabilities_1"         AS BIGINT), 0) AS PYLiabilitiesCurrent,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Total Liabilities_1"           AS BIGINT), 0) AS PYLiabilitiesTotal,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Retained Earnings/(Deficit)_1" AS BIGINT), 0) AS PYRetainedEarnings,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_balance_sheet.Stockholders' Equity_1"        AS BIGINT), 0) AS PYEquity,
	ROUND(fxYear * "financial_reports.annual_balance_sheet.Book Value Per Share_1"                                      , 2) AS PYBVPS,
	----- INCOME STATEMENT, CURRENT YEAR
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_income_statement.Gross Revenue"                 AS BIGINT), 0) AS CYRevenue,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_income_statement.Net Income/(Loss) After Tax"   AS BIGINT), 0) AS CYIncome,
	ROUND(fxYear * "financial_reports.annual_income_statement.Earnings/(Loss) Per Share (Basic)"                           , 2) AS CYEPS,
	----- INCOME STATEMENT, PREVIOUS YEAR
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_income_statement.Gross Revenue_1"               AS BIGINT), 0) AS PYRevenue,
	ROUND(CAST(multipleYear * fxYear * "financial_reports.annual_income_statement.Net Income/(Loss) After Tax_1" AS BIGINT), 0) AS PYIncome,
	ROUND(fxYear * "financial_reports.annual_income_statement.Earnings/(Loss) Per Share (Basic)_1"                         , 2) AS PYEPS,
	--------------------------------------------------
	FiscalQuarterEnd,
	----- BALANCE SHEET, CURRENT QUARTER
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Current Assets" 			   AS BIGINT), 0) AS CQAssetsCurrent,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Total Assets" 			       AS BIGINT), 0) AS CQAssetsTotal,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Current Liabilities"           AS BIGINT), 0) AS CQLiabilitiesCurrent,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Total Liabilities"             AS BIGINT), 0) AS CQLiabilitiesTotal,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Retained Earnings/(Deficit)"   AS BIGINT), 0) AS CQRetainedEarnings,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Stockholders' Equity" 	       AS BIGINT), 0) AS CQEquity,
	ROUND(fxQuarter * "financial_reports.quarterly_balance_sheet.Book Value Per Share" 							                 , 2) AS CQBVPS,
	----- BALANCE SHEET, PREVIOUS QUARTER
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Current Assets_1" 		       AS BIGINT), 0) AS PQAssetsCurrent,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Total Assets_1" 			   AS BIGINT), 0) AS PQAssetsTotal,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Current Liabilities_1" 	       AS BIGINT), 0) AS PQLiabilitiesCurrent,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Total Liabilities_1" 		   AS BIGINT), 0) AS PQLiabilitiesTotal,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Retained Earnings/(Deficit)_1" AS BIGINT), 0) AS PQRetainedEarnings,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_balance_sheet.Stockholders' Equity_1" 	   AS BIGINT), 0) AS PQEquity,
	ROUND(fxQuarter * "financial_reports.quarterly_balance_sheet.Book Value Per Share_1" 										 , 2) AS PQBVPS,
	----- INCOME STATEMENT, CURRENT QUARTER
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Gross Revenue" 			      AS BIGINT), 0) AS CQRevenue,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax"   AS BIGINT), 0) AS CQIncome,
	ROUND(fxQuarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)" 					    		, 2) AS CQEPS,
	----- INCOME STATEMENT, PREVIOUS QUARTER
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Gross Revenue_1" 		  	  AS BIGINT), 0) AS PQRevenue,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_1" AS BIGINT), 0) AS PQIncome,
	ROUND(fxQuarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_1" 						    , 2) AS PQEPS,
	----- INCOME STATEMENT, CURRENT YEAR TO DATE
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Gross Revenue_2" 			  AS BIGINT), 0) AS CYytdRevenue,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_2" AS BIGINT), 0) AS CYytdIncome,
	ROUND(fxQuarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_2" 							, 2) AS CYytdEPS,
	----- INCOME STATEMENT, PREVIOUS YEAR TO DATE
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Gross Revenue_3" 			  AS BIGINT), 0) AS PYytdRevenue,
	ROUND(CAST(multipleQuarter * fxQuarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_3" AS BIGINT), 0) AS PYytdIncome,
	ROUND(fxQuarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_3" 							, 2) AS PYytdEPS,
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
	RelativeMarketRSI5, RelativeMarketRSI10, RelativeMarketRSI20, RelativeMarketRSI30, RelativeMarketRSI60, RelativeMarketRSI120, RelativeMarketRSI240, 
	RelativeSectorRSI5, RelativeSectorRSI10, RelativeSectorRSI20, RelativeSectorRSI30, RelativeSectorRSI60, RelativeSectorRSI120, RelativeSectorRSI240, 
	RelativeIndustryRSI5, RelativeIndustryRSI10, RelativeIndustryRSI20, RelativeIndustryRSI30, RelativeIndustryRSI60, RelativeIndustryRSI120, RelativeIndustryRSI240, 

FROM {{ ref('normalize_values') }}