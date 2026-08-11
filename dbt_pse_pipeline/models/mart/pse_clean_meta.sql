{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT
    "Symbol", "Name", "Description", "Sector", "Industry", "Fiscal Year End"
    , TRY_CAST(ROUND("Market Cap", 0) AS BIGINT) AS "Market Cap"
    , TRY_CAST(ROUND("Float Pct", 2) AS NUMERIC) AS "Float Pct"
    , TRY_CAST(ROUND("CY Current Assets", 0) AS BIGINT) AS "CY Current Assets"
    , TRY_CAST(ROUND("CY Total Assets", 0) AS BIGINT) AS "CY Total Assets"
    , TRY_CAST(ROUND("CY Current Liabilities", 0) AS BIGINT) AS "CY Current Liabilities"
    , TRY_CAST(ROUND("CY Total Liabilities", 0) AS BIGINT) AS "CY Total Liabilities"
    , TRY_CAST(ROUND("CY Retained Earnings", 0) AS BIGINT) AS "CY Retained Earnings"
    , TRY_CAST(ROUND("CY Equity", 0) AS BIGINT) AS "CY Equity"
    , TRY_CAST(ROUND("CY BVPS", 4) AS NUMERIC) AS "CY BVPS"
    , TRY_CAST(ROUND("CY Revenue", 0) AS BIGINT) AS "CY Revenue"
    , TRY_CAST(ROUND("CY Income", 0) AS BIGINT) AS "CY Income"
    , TRY_CAST(ROUND("CY EPS", 4) AS NUMERIC) AS "CY EPS"
    , TRY_CAST(ROUND("CQ Current Assets", 0) AS BIGINT) AS "CQ Current Assets"
    , TRY_CAST(ROUND("CQ Total Assets", 0) AS BIGINT) AS "CQ Total Assets"
    , TRY_CAST(ROUND("CQ Current Liabilities", 0) AS BIGINT) AS "CQ Current Liabilities"
    , TRY_CAST(ROUND("CQ Total Liabilities", 0) AS BIGINT) AS "CQ Total Liabilities"
    , TRY_CAST(ROUND("CQ Retained Earnings", 0) AS BIGINT) AS "CQ Retained Earnings"
    , TRY_CAST(ROUND("CQ Equity", 0) AS BIGINT) AS "CQ Equity"
    , TRY_CAST(ROUND("CQ BVPS", 4) AS NUMERIC) AS "CQ BVPS"
    , TRY_CAST(ROUND("CQ Revenue", 0) AS BIGINT) AS "CQ Revenue"
    , TRY_CAST(ROUND("CQ Income", 0) AS BIGINT) AS "CQ Income"
    , TRY_CAST(ROUND("CQ EPS", 4) AS NUMERIC) AS "CQ EPS"
    , TRY_CAST(ROUND("CY YTD Revenue", 0) AS BIGINT) AS "CY YTD Revenue"
    , TRY_CAST(ROUND("CY YTD Income", 0) AS BIGINT) AS "CY YTD Income"
    , TRY_CAST(ROUND("CY YTD EPS", 4) AS NUMERIC) AS "CY YTD EPS"
    , TRY_CAST(ROUND("TTM Revenue", 0) AS BIGINT) AS "TTM Revenue"
    , TRY_CAST(ROUND("TTM Income", 0) AS BIGINT) AS "TTM Income"
    , TRY_CAST(ROUND("TTM EPS", 4) AS NUMERIC) AS "TTM EPS"
    , TRY_CAST(ROUND("Revenue Growth", 2) AS NUMERIC) AS "Revenue Growth"
    , TRY_CAST(ROUND("Income Growth", 2) AS NUMERIC) AS "Income Growth"
    , TRY_CAST(ROUND("EPS Growth", 2) AS NUMERIC) AS "EPS Growth"
    , TRY_CAST(ROUND("Income Margin", 2) AS NUMERIC) AS "Income Margin"
    , TRY_CAST(ROUND("Return On Assets", 2) AS NUMERIC) AS "Return On Assets"
    , TRY_CAST(ROUND("Return On Equity", 2) AS NUMERIC) AS "Return On Equity"
    , TRY_CAST(ROUND("Current Ratio", 2) AS NUMERIC) AS "Current Ratio"
    , TRY_CAST(ROUND("Debt Ratio", 2) AS NUMERIC) AS "Debt Ratio"
    , TRY_CAST(ROUND("D/E Ratio", 2) AS NUMERIC) AS "D/E Ratio"
    , TRY_CAST(ROUND("P/S", 2) AS NUMERIC) AS "P/S"
    , TRY_CAST(ROUND("P/E", 2) AS NUMERIC) AS "P/E"
    , TRY_CAST(ROUND("PS/G", 2) AS NUMERIC) AS "PS/G"
    , TRY_CAST(ROUND("PE/G", 2) AS NUMERIC) AS "PE/G"
    , TRY_CAST(ROUND("P/BV Ratio", 2) AS NUMERIC) AS "P/BV Ratio"
    , TRY_CAST(ROUND("Close", 2) AS NUMERIC) AS "Close"
    , TRY_CAST(ROUND("Chg", 2) AS NUMERIC) AS "Chg"
    , TRY_CAST(ROUND("Value", 0) AS BIGINT) AS "Value"
    , TRY_CAST(ROUND("Volume", 0) AS BIGINT) AS "Volume"
    , TRY_CAST(ROUND("MA20", 2) AS NUMERIC) AS "MA20"
    , TRY_CAST(ROUND("MA60", 2) AS NUMERIC) AS "MA60"
    , TRY_CAST(ROUND("MA240", 2) AS NUMERIC) AS "MA240"
    , TRY_CAST(ROUND("RSI20", 2) AS NUMERIC) AS "RSI20"
    , TRY_CAST(ROUND("RSI60", 2) AS NUMERIC) AS "RSI60"
    , TRY_CAST(ROUND("RSI240", 2) AS NUMERIC) AS "RSI240"
    , TRY_CAST(ROUND("Month High", 2) AS NUMERIC) AS "Month High"
    , TRY_CAST(ROUND("Month Low", 2) AS NUMERIC) AS "Month Low"
    , TRY_CAST(ROUND("Quarter High", 2) AS NUMERIC) AS "Quarter High"
    , TRY_CAST(ROUND("Quarter Low", 2) AS NUMERIC) AS "Quarter Low"
    , TRY_CAST(ROUND("Year High", 2) AS NUMERIC) AS "Year High"
    , TRY_CAST(ROUND("Year Low", 2) AS NUMERIC) AS "Year Low"
    , TRY_CAST(ROUND("All Time High", 2) AS NUMERIC) AS "All Time High"
    , TRY_CAST(ROUND("All Time Low", 2) AS NUMERIC) AS "All Time Low"
    , TRY_CAST(ROUND("Market RSI20", 2) AS NUMERIC) AS "Market RSI20"
    , TRY_CAST(ROUND("Market RSI60", 2) AS NUMERIC) AS "Market RSI60"
    , TRY_CAST(ROUND("Market RSI240", 2) AS NUMERIC) AS "Market RSI240"
    , TRY_CAST(ROUND("Sector RSI20", 2) AS NUMERIC) AS "Sector RSI20"
    , TRY_CAST(ROUND("Sector RSI60", 2) AS NUMERIC) AS "Sector RSI60"
    , TRY_CAST(ROUND("Sector RSI240", 2) AS NUMERIC) AS "Sector RSI240"
    , TRY_CAST(ROUND("Industry RSI20", 2) AS NUMERIC) AS "Industry RSI20"
    , TRY_CAST(ROUND("Industry RSI60", 2) AS NUMERIC) AS "Industry RSI60"
    , TRY_CAST(ROUND("Industry RSI240", 2) AS NUMERIC) AS "Industry RSI240"
    , TRY_CAST(ROUND("Relative Month High", 2) AS NUMERIC) AS "Relative Month High"
    , TRY_CAST(ROUND("Relative Month Low", 2) AS NUMERIC) AS "Relative Month Low"
    , TRY_CAST(ROUND("Relative Quarter High", 2) AS NUMERIC) AS "Relative Quarter High"
    , TRY_CAST(ROUND("Relative Quarter Low", 2) AS NUMERIC) AS "Relative Quarter Low"
    , TRY_CAST(ROUND("Relative Year High", 2) AS NUMERIC) AS "Relative Year High"
    , TRY_CAST(ROUND("Relative Year Low", 2) AS NUMERIC) AS "Relative Year Low"
    , TRY_CAST(ROUND("Relative All Time High", 2) AS NUMERIC) AS "Relative All Time High"
    , TRY_CAST(ROUND("Relative All Time Low", 2) AS NUMERIC) AS "Relative All Time Low"
    , TRY_CAST(ROUND("Relative Market RSI 20", 2) AS NUMERIC) AS "Relative Market RSI 20"
    , TRY_CAST(ROUND("Relative Market RSI 60", 2) AS NUMERIC) AS "Relative Market RSI 60"
    , TRY_CAST(ROUND("Relative Market RSI 240", 2) AS NUMERIC) AS "Relative Market RSI 240"
    , TRY_CAST(ROUND("Relative Sector RSI 20", 2) AS NUMERIC) AS "Relative Sector RSI 20"
    , TRY_CAST(ROUND("Relative Sector RSI 60", 2) AS NUMERIC) AS "Relative Sector RSI 60"
    , TRY_CAST(ROUND("Relative Sector RSI 240", 2) AS NUMERIC) AS "Relative Sector RSI 240"
    , TRY_CAST(ROUND("Relative Industry RSI 20", 2) AS NUMERIC) AS "Relative Industry RSI 20"
    , TRY_CAST(ROUND("Relative Industry RSI 60", 2) AS NUMERIC) AS "Relative Industry RSI 60"
    , TRY_CAST(ROUND("Relative Industry RSI 240", 2) AS NUMERIC) AS "Relative Industry RSI 240"
    ,
        CASE
            WHEN High == "All Time High" THEN 'All Time High'
    		WHEN High == "Year High"     THEN 'Year High'
    		WHEN High == "Quarter High"  THEN 'Quarter High'
    			ELSE '' END AS "Breakout Alert",
        CASE
    		WHEN Low == "All Time Low" THEN 'All Time Low'
    		WHEN Low == "Year Low"     THEN 'Year Low'
    		WHEN Low == "Quarter Low"  THEN 'Quarter Low'
    			ELSE '' END AS "Breakdown Alert",
    	CASE
    		WHEN RSI20 < 10 THEN 'Panic'
    		WHEN RSI20 < 20 THEN 'Oversold'
    		WHEN RSI20 > 90 THEN 'Euphoric'
    		WHEN RSI20 > 80 THEN 'Overbought'
    			ELSE '' END AS "Behavioral Alert"

FROM {{ ref('compute_ratios') }}
ORDER BY "Market Cap" DESC