import os
import supabase
import yfinance as yf
import duckdb

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_KEY"]
client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)
s3_endpoint = 'mckyuuzvkuxzfkjoucyo.supabase.co/storage/v1/s3'
S3_KEY = os.environ["SUPABASE_S3_ACCESS_KEY_ID"]
S3_SECRET = os.environ["SUPABASE_S3_SECRET_ACCESS_KEY"]
s3_region = 'ap-northeast-1'
s3_url_style = 'path'


# # # # # MERGE DATA # # # # # 

get_price = duckdb.sql(f"""
    INSTALL httpfs;
    LOAD httpfs;
    SET s3_endpoint='{s3_endpoint}';
    SET s3_access_key_id='{S3_KEY}';
    SET s3_secret_access_key='{S3_SECRET}';
    SET s3_region='{s3_region}';
    SET s3_url_style='{s3_url_style}';
    SELECT *
    FROM read_parquet('s3://pse-price/*.parquet', union_by_name=True)
""")

get_meta = duckdb.sql(f"""
    INSTALL httpfs;
    LOAD httpfs;
    SET s3_endpoint='{s3_endpoint}';
    SET s3_access_key_id='{S3_KEY}';
    SET s3_secret_access_key='{S3_SECRET}';
    SET s3_region='{s3_region}';
    SET s3_url_style='{s3_url_style}';
    SELECT *,
        regexp_replace(
            regexp_replace(
                regexp_replace("company_details.subsector",
                    ',', '', 'g'),
                    'and', '&', 'g'),
                    'Infrastructure', 'Infra.', 'g') AS clean_industry
    FROM read_parquet('s3://pse-meta/*.parquet', union_by_name=True)
""")


# # # # # CTE PRICE FACTORY # # # # # 

df_price = duckdb.sql("""
    WITH 
    clean AS (
        WITH tag AS (
            SELECT a.*,
                b."company_details.sector" AS Sector,
                clean_industry AS Industry,
                TRY_CAST((((close / LAG(close) OVER (PARTITION BY symbol ORDER BY date ASC)) - 1) * 100) AS DOUBLE) AS Chg
            FROM get_price a
            JOIN meta b ON a.symbol = b."company_info.symbol"
        )
        SELECT
            TRY_CAST(Date AS DATE) AS Date, 
            symbol				   AS Symbol,
            Sector, Industry, 
            ROUND(TRY_CAST(Chg   AS DOUBLE), 2) AS Chg,
            ROUND(TRY_CAST(Open  AS DOUBLE), 2) AS Open,
            ROUND(TRY_CAST(High  AS DOUBLE), 2) AS High,
            ROUND(TRY_CAST(Low   AS DOUBLE), 2) AS Low,
            ROUND(TRY_CAST(Close AS DOUBLE), 2) AS Close,
            ROUND(TRY_CAST(CASE WHEN Chg > 0 THEN Chg      ELSE 0 END AS DOUBLE), 2) AS Gain,
            ROUND(TRY_CAST(CASE WHEN Chg < 0 THEN ABS(Chg) ELSE 0 END AS DOUBLE), 2) AS Loss,
            ROUND(TRY_CAST(Value AS BIGINT), 0)												    AS Value,
            ROUND(TRY_CAST(TRY_CAST(Value AS BIGINT) / TRY_CAST(Close AS DOUBLE) AS BIGINT), 0)	AS Volume
        FROM tag
        ORDER BY Date ASC
    ),
    time_series_monthly AS (
        SELECT *,
            MAX(High)  OVER w AS "Month High",
            MIN(Low)   OVER w AS "Month Low",
            MAX(Chg)   OVER w AS "Month Chg High",
            MIN(Chg)   OVER w AS "Month Chg Low",
            MAX(Value) OVER w AS "Month Val High",
            MIN(Value) OVER w AS "Month Val Low",
            ROUND(AVG(Close) OVER w, 2) AS MA20,
            ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI20
        FROM clean
        WINDOW w AS (
            PARTITION BY Symbol ORDER BY Date
            ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
        )
    ),
    time_series_quarterly AS (
        SELECT *,
            MAX(High)  OVER w AS "Quarter High",
            MIN(Low)   OVER w AS "Quarter Low",
            MAX(Chg)   OVER w AS "Quarter Chg High",
            MIN(Chg)   OVER w AS "Quarter Chg Low",
            MAX(Value) OVER w AS "Quarter Val High",
            MIN(Value) OVER w AS "Quarter Val Low",
            ROUND(AVG(Close) OVER w, 2) AS MA60,
            ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI60
        FROM time_series_monthly
        WINDOW w AS (
            PARTITION BY Symbol ORDER BY Date
            ROWS BETWEEN 59 PRECEDING AND CURRENT ROW ----------> simplify, just 20x3
        )
    ),
    time_series_yearly AS (
        SELECT *,
            MAX(High)  OVER w AS "Year High",
            MIN(Low)   OVER w AS "Year Low",
            MAX(Chg)   OVER w AS "Year Chg High",
            MIN(Chg)   OVER w AS "Year Chg Low",
            MAX(Value) OVER w AS "Year Val High",
            MIN(Value) OVER w AS "Year Val Low",
            ROUND(AVG(Close) OVER w, 2) AS MA240,
            ROUND(TRY_CAST(100 - (100 / (1 + (AVG(Gain) OVER w) / NULLIF((AVG(Loss) OVER w), 0))) AS DOUBLE), 2) AS RSI240
        FROM time_series_quarterly
        WINDOW w AS (
            PARTITION BY Symbol ORDER BY Date
            ROWS BETWEEN 239 PRECEDING AND CURRENT ROW ----------> simplify, just 20x12
        )
    ),
    breadth AS (
        SELECT *,
            ROUND(AVG(RSI20)  OVER (PARTITION BY Date)          , 2) AS "Market RSI20",
            ROUND(AVG(RSI60)  OVER (PARTITION BY Date)          , 2) AS "Market RSI60",
            ROUND(AVG(RSI240) OVER (PARTITION BY Date)          , 2) AS "Market RSI240",
            ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI20",
            ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI60",
            ROUND(AVG(RSI240) OVER (PARTITION BY Date, Sector)  , 2) AS "Sector RSI240",
            ROUND(AVG(RSI20)  OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI20",
            ROUND(AVG(RSI60)  OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI60",
            ROUND(AVG(RSI240) OVER (PARTITION BY Date, Industry), 2) AS "Industry RSI240"
        FROM time_series_yearly
    ),
    relative AS (
        SELECT *,
            ROUND(((Close  / "Month High")      - 1) * 100, 2) AS "Relative Month High",
            ROUND(((Close  / "Month Low")       - 1) * 100, 2) AS "Relative Month Low",
            ROUND(((Close  / "Quarter High")    - 1) * 100, 2) AS "Relative Quarter High",
            ROUND(((Close  / "Quarter Low")     - 1) * 100, 2) AS "Relative Quarter Low",
            ROUND(((Close  / "Year High")       - 1) * 100, 2) AS "Relative Year High",
            ROUND(((Close  / "Year Low")        - 1) * 100, 2) AS "Relative Year Low",
            ROUND(((RSI20  / "Market RSI20")	- 1) * 100, 2) AS "Relative Market RSI 20",
            ROUND(((RSI60  / "Market RSI60") 	- 1) * 100, 2) AS "Relative Market RSI 60",
            ROUND(((RSI240 / "Market RSI240")   - 1) * 100, 2) AS "Relative Market RSI 240",
            ROUND(((RSI20  / "Sector RSI20")    - 1) * 100, 2) AS "Relative Sector RSI 20",
            ROUND(((RSI60  / "Sector RSI60")    - 1) * 100, 2) AS "Relative Sector RSI 60",
            ROUND(((RSI240 / "Sector RSI240")   - 1) * 100, 2) AS "Relative Sector RSI 240",
            ROUND(((RSI20  / "Industry RSI20")  - 1) * 100, 2) AS "Relative Industry RSI 20",
            ROUND(((RSI60  / "Industry RSI60")  - 1) * 100, 2) AS "Relative Industry RSI 60",
            ROUND(((RSI240 / "Industry RSI240") - 1) * 100, 2) AS "Relative Industry RSI 240"
        FROM breadth
    ),
    time_series_alltime AS (
        SELECT *,
            MAX(High)	OVER w AS "All Time High",
            MIN(Low) 	OVER w AS "All Time Low",
            MAX(Chg) 	OVER w AS "All Time Chg High",
            MIN(Chg) 	OVER w AS "All Time Chg Low",
            MAX(Value)  OVER w AS "All Time Val High",
            MIN(Value)  OVER w AS "All Time Val Low",
            MAX(RSI20)  OVER w AS "All Time RSI20 High",
            MIN(RSI20)  OVER w AS "All Time RSI20 Low",
            MAX(RSI60)  OVER w AS "All Time RSI60 High",
            MIN(RSI60)  OVER w AS "All Time RSI60 Low",
            MAX(RSI240) OVER w AS "All Time RSI240 High",
            MIN(RSI240) OVER w AS "All Time RSI240 Low"
        FROM relative
        WINDOW w AS (
            PARTITION BY Symbol ORDER BY Date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    )
    SELECT *,
        ROUND(((Close / "All Time High") - 1) * 100, 2) AS "Relative All Time High",
        ROUND(((Close / "All Time Low")  - 1) * 100, 2) AS "Relative All Time Low",
    FROM time_series_alltime
""").fetchdf()

df_price_last_day = duckdb.sql("""
    SELECT *
    FROM df_price
    WHERE Date = (SELECT MAX(Date) FROM df_price)
""").fetchdf()

df_price_curr_year = duckdb.sql("""
    SELECT * 
    FROM df_price 
    WHERE YEAR(Date) = 2026
""").fetchdf() # upload to supabase

df_price.to_parquet('pse_clean_price_full.parquet', index=False)      # store locally (above supabase limit)
df_price_curr_year.to_parquet('pse_clean_price.parquet', index=False) # send to supabase

with open('pse_clean_price.parquet', 'rb') as f:
    client.storage.from_("pse-clean").upload(
        'pse_clean_price.parquet',
        f,
        {"upsert": "true"}
    )


# # # # # CTE META FACTORY # # # # # 

usdphp = yf.Ticker("USDPHP=X").history(period="2y")['Close'].mean() # simplify, just get 2 year average
cadphp = yf.Ticker("CADPHP=X").history(period="2y")['Close'].mean()

df_meta = duckdb.sql(f"""
    WITH 
    df_clean AS (
        WITH 
        pre_join AS (
            SELECT *
            FROM get_meta a 
            LEFT JOIN df_price_last_day b ON a."company_info.symbol" = b.Symbol
        ),
        pre_clean AS (
            SELECT * EXCLUDE (
                "stock_data.market_cap",
                "stock_data.outstanding_shares",
                "stock_data.free_float_percent"
            ),
            ROUND(TRY_CAST(regexp_replace("stock_data.market_cap", ',', '', 'g')         AS DOUBLE), 0) AS "Market Cap",
            ROUND(TRY_CAST(regexp_replace("stock_data.outstanding_shares", ',', '', 'g') AS DOUBLE), 0) AS "Shares Out",
            ROUND(TRY_CAST(regexp_replace("stock_data.free_float_percent", '%', '')      AS DOUBLE), 2) AS "Float Pct"
            FROM pre_join
        )
        SELECT 
            "company_info.symbol" AS Symbol,
            "company_info.name"   AS Name,
            "company_details.company_description" AS Description,
            "company_details.sector" AS Sector,
            clean_industry AS Industry,
            "Market Cap", "Shares Out", "Float Pct",
            ROUND("Shares Out" * "Float Pct" / 100, 0) AS "Shares Float",

            TRY_CAST(strptime("financial_reports.annual_fiscal_year_ended", '%b %d, %Y') AS DATE) AS "Fiscal Year End",
			----- ANNUAL FX CONVERT
            CAST(CASE 
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%c$%'	 THEN {cadphp}
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%$%' 	 THEN {usdphp}
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%usd%' 	 THEN {usdphp}
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%dollar%' THEN {usdphp}
                    ELSE 1 END AS DOUBLE) AS fx_year,
            CAST(CASE
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%mil%'  THEN 1000000
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%thou%' THEN 1000
                WHEN LOWER("financial_reports.annual_currency") ILIKE '%000%'  THEN 1000
                    ELSE 1 END AS DOUBLE) AS multiple_year,
			----- ANNUAL FINANCIAL STATEMENTS
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\\"\\,\\[\\]]', '', 'g'), ' ', 1) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_balance'), '[\\"\\,\\[\\]]', '', 'g'), ' ', 2) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 1) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.annual_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 2) AS DOUBLE),

            TRY_CAST(strptime("financial_reports.quarterly_period_ended", '%b %d, %Y') AS DATE) AS "Fiscal Quarter End",
			----- QUARTERLY FX CONVERT
            CAST(CASE 
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%c$%'	    THEN {cadphp}
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%$%'		THEN {usdphp}	
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%usd%' 	THEN {usdphp}
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%dollar%' THEN {usdphp}
                    ELSE 1 END AS DOUBLE) AS fx_quarter,
            CAST(CASE
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%mil%'  THEN 1000000
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%thou%' THEN 1000
                WHEN LOWER("financial_reports.quarterly_currency") ILIKE '%000%'  THEN 1000
                    ELSE 1 END AS DOUBLE) AS multiple_quarter,
			----- QUARTERLY FINANCIAL STATEMENTS
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\\"\\,\\[\\]]', '', 'g'), ' ', 1) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_balance'), '[\\"\\,\\[\\]]', '', 'g'), ' ', 2) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 1) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 2) AS DOUBLE),        
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 3) AS DOUBLE),
            TRY_CAST(split_part(regexp_replace(COLUMNS('financial_reports.quarterly_income'),  '[\\"\\,\\[\\]]', '', 'g'), ' ', 4) AS DOUBLE),
			----- LAST PRICE AND INDICATOR VALUES
			Open, High, Low, Close, Chg, Gain, Loss, Value, Volume, MA20, RSI20, MA60, RSI60, MA240, RSI240, 
			"Month High", "Month Low", "Month Chg High", "Month Chg Low", "Month Val High", "Month Val Low",
			"Quarter High", "Quarter Low", "Quarter Chg High", "Quarter Chg Low", "Quarter Val High", "Quarter Val Low",
			"Year High", "Year Low", "Year Chg High", "Year Chg Low", "Year Val High", "Year Val Low",
			"Market RSI20", "Market RSI60", "Market RSI240", 
			"Sector RSI20", "Sector RSI60", "Sector RSI240", 
			"Industry RSI20", "Industry RSI60", "Industry RSI240", 
			"Relative Month High", "Relative Month Low",
			"Relative Quarter High", "Relative Quarter Low",
			"Relative Year High", "Relative Year Low", 
			"Relative All Time High", "Relative All Time Low",
			"Relative Market RSI 20", "Relative Market RSI 60", "Relative Market RSI 240",
			"Relative Sector RSI 20", "Relative Sector RSI 60", "Relative Sector RSI 240", 
			"Relative Industry RSI 20", "Relative Industry RSI 60", "Relative Industry RSI 240", 
			"All Time High", "All Time Low",
			"All Time Chg High", "All Time Chg Low",
			"All Time Val High", "All Time Val Low", 
			"All Time RSI20 High", "All Time RSI20 Low",
			"All Time RSI60 High", "All Time RSI60 Low",
			"All Time RSI240 High", "All Time RSI240 Low"
        FROM pre_clean
    ),
    df_cleaner AS (
        SELECT
            Symbol, Name, Description, Sector, Industry, "Market Cap", "Shares Out", "Shares Float", "Float Pct",

			"Fiscal Year End",
            ----- BALANCE SHEET, CURRENT YEAR
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Current Assets"              AS BIGINT), 0) AS "CY Current Assets",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Total Assets"                AS BIGINT), 0) AS "CY Total Assets",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Current Liabilities"         AS BIGINT), 0) AS "CY Current Liabilities",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Total Liabilities"           AS BIGINT), 0) AS "CY Total Liabilities",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Retained Earnings/(Deficit)" AS BIGINT), 0) AS "CY Retained Earnings",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Stockholders' Equity"        AS BIGINT), 0) AS "CY Equity",
            ROUND(fx_year * "financial_reports.annual_balance_sheet.Book Value Per Share"                                       , 2) AS "CY BVPS",
			----- BALANCE SHEET, PREVIOUS YEAR
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Current Assets_1"              AS BIGINT), 0) AS "PY Current Assets",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Total Assets_1"                AS BIGINT), 0) AS "PY Total Assets",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Current Liabilities_1"         AS BIGINT), 0) AS "PY Current Liabilities",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Total Liabilities_1"           AS BIGINT), 0) AS "PY Total Liabilities",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Retained Earnings/(Deficit)_1" AS BIGINT), 0) AS "PY Retained Earnings",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_balance_sheet.Stockholders' Equity_1"        AS BIGINT), 0) AS "PY Equity",
            ROUND(fx_year * "financial_reports.annual_balance_sheet.Book Value Per Share_1"                                       , 2) AS "PY BVPS",
			----- INCOME STATEMENT, CURRENT YEAR
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_income_statement.Gross Revenue"               AS BIGINT), 0) AS "CY Revenue",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_income_statement.Net Income/(Loss) After Tax" AS BIGINT), 0) AS "CY Income",
            ROUND(fx_year * "financial_reports.annual_income_statement.Earnings/(Loss) Per Share (Basic)"                          , 2) AS "CY EPS",
			----- INCOME STATEMENT, PREVIOUS YEAR
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_income_statement.Gross Revenue_1"               AS BIGINT), 0) AS "PY Revenue",
            ROUND(CAST(multiple_year * fx_year * "financial_reports.annual_income_statement.Net Income/(Loss) After Tax_1" AS BIGINT), 0) AS "PY Income",
            ROUND(fx_year * "financial_reports.annual_income_statement.Earnings/(Loss) Per Share (Basic)_1"                          , 2) AS "PY EPS",

			"Fiscal Quarter End",
            ----- BALANCE SHEET, CURRENT QUARTER
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Current Assets" 			   AS BIGINT), 0) AS "CQ Current Assets",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Total Assets" 			   AS BIGINT), 0) AS "CQ Total Assets",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Current Liabilities"         AS BIGINT), 0) AS "CQ Current Liabilities",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Total Liabilities"           AS BIGINT), 0) AS "CQ Total Liabilities",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Retained Earnings/(Deficit)" AS BIGINT), 0) AS "CQ Retained Earnings",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Stockholders' Equity" 	   AS BIGINT), 0) AS "CQ Equity",
            ROUND(fx_quarter * "financial_reports.quarterly_balance_sheet.Book Value Per Share" 							             , 2) AS "CQ BVPS",
			----- BALANCE SHEET, PREVIOUS QUARTER
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Current Assets_1" 		     AS BIGINT), 0) AS "PQ Current Assets",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Total Assets_1" 			     AS BIGINT), 0) AS "PQ Total Assets",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Current Liabilities_1" 	     AS BIGINT), 0) AS "PQ Current Liabilities",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Total Liabilities_1" 		     AS BIGINT), 0) AS "PQ Total Liabilities",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Retained Earnings/(Deficit)_1" AS BIGINT), 0) AS "PQ Retained Earnings",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_balance_sheet.Stockholders' Equity_1" 	     AS BIGINT), 0) AS "PQ Equity",
            ROUND(fx_quarter * "financial_reports.quarterly_balance_sheet.Book Value Per Share_1" 										   , 2) AS "PQ BVPS",
			----- INCOME STATEMENT, CURRENT QUARTER
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Gross Revenue" 			  AS BIGINT), 0) AS "CQ Revenue",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax" AS BIGINT), 0) AS "CQ Income",
            ROUND(fx_quarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)" 							, 2) AS "CQ EPS",
			----- INCOME STATEMENT, PREVIOUS QUARTER
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Gross Revenue_1" 		  	    AS BIGINT), 0) AS "PQ Revenue",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_1" AS BIGINT), 0) AS "PQ Income",
            ROUND(fx_quarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_1" 						      , 2) AS "PQ EPS",
			----- INCOME STATEMENT, CURRENT YEAR TO DATE
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Gross Revenue_2" 			    AS BIGINT), 0) AS "CY YTD Revenue",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_2" AS BIGINT), 0) AS "CY YTD Income",
            ROUND(fx_quarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_2" 							  , 2) AS "CY YTD EPS",
			----- INCOME STATEMENT, PREVIOUS YEAR TO DATE
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Gross Revenue_3" 			    AS BIGINT), 0) AS "PY YTD Revenue",
            ROUND(CAST(multiple_quarter * fx_quarter * "financial_reports.quarterly_income_statement.Net Income/(Loss) After Tax_3" AS BIGINT), 0) AS "PY YTD Income",
            ROUND(fx_quarter * "financial_reports.quarterly_income_statement.Earnings/(Loss) Per Share (Basic)_3" 							  , 2) AS "PY YTD EPS",
			----- LAST PRICE AND INDICATOR VALUES
			Open, High, Low, Close, Chg, Gain, Loss, Value, Volume, MA20, RSI20, MA60, RSI60, MA240, RSI240, 
			"Month High", "Month Low", "Month Chg High", "Month Chg Low", "Month Val High", "Month Val Low",
			"Quarter High", "Quarter Low", "Quarter Chg High", "Quarter Chg Low", "Quarter Val High", "Quarter Val Low",
			"Year High", "Year Low", "Year Chg High", "Year Chg Low", "Year Val High", "Year Val Low",
			"Market RSI20", "Market RSI60", "Market RSI240", 
			"Sector RSI20", "Sector RSI60", "Sector RSI240", 
			"Industry RSI20", "Industry RSI60", "Industry RSI240", 
			"Relative Month High", "Relative Month Low",
			"Relative Quarter High", "Relative Quarter Low",
			"Relative Year High", "Relative Year Low", 
			"Relative All Time High", "Relative All Time Low",
			"Relative Market RSI 20", "Relative Market RSI 60", "Relative Market RSI 240",
			"Relative Sector RSI 20", "Relative Sector RSI 60", "Relative Sector RSI 240", 
			"Relative Industry RSI 20", "Relative Industry RSI 60", "Relative Industry RSI 240", 
			"All Time High", "All Time Low",
			"All Time Chg High", "All Time Chg Low",
			"All Time Val High", "All Time Val Low", 
			"All Time RSI20 High", "All Time RSI20 Low",
			"All Time RSI60 High", "All Time RSI60 Low",
			"All Time RSI240 High", "All Time RSI240 Low"
        FROM df_clean
    ),
    df_cleanest AS (
        WITH 
        ttm AS (
            SELECT *,
                "CY Revenue" - "PY YTD Revenue" + "CY YTD Revenue" AS "TTM Revenue",
                "CY Income"  - "PY YTD Income"  + "CY YTD Income"  AS "TTM Income",
                "CY EPS"     - "PY YTD EPS"     + "CY YTD EPS"     AS "TTM EPS"
            FROM df_cleaner
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
    )
    SELECT *,
        CASE
            WHEN High == "All Time High" THEN 'ATHigh'
            WHEN High == "Year High"     THEN 'YHigh'
            WHEN High == "Quarter High"  THEN 'QHigh'
                ELSE '' END AS "Breakout Alert",
        CASE
            WHEN Low == "All Time Low" THEN 'ATLow'
            WHEN Low == "Year Low"     THEN 'YLow'
            WHEN Low == "Quarter Low"  THEN 'QLow'
                ELSE '' END AS "Breakdown Alert",
        CASE
            WHEN RSI20 < 10 THEN 'Panic'
            WHEN RSI20 < 20 THEN 'Oversold'
            WHEN RSI20 > 90 THEN 'Euphoric'
            WHEN RSI20 > 80 THEN 'Overbought'
                ELSE '' END AS "Behavioral Alert"
    FROM df_cleanest
    ORDER BY "Market Cap" DESC
""").fetchdf()

df_meta.to_parquet('pse_clean_meta.parquet', index=False)

with open('pse_clean_meta.parquet', 'rb') as f:
    client.storage.from_("pse-clean").upload(
        'pse_clean_meta.parquet',
        f,
        {"upsert": "true"}
    )


# # # # # CTE AGG FACTORY # # # # # 

df_agg = duckdb.sql("""
    WITH
    pre_agg AS (
        WITH
        market_agg AS (
            SELECT 'PSE' AS Sector, 'PSE' AS Industry, 
                COUNT(*) AS Count,
                ROUND(CAST(SUM("Value")                AS BIGINT), 0) AS Turnover,
                ROUND(CAST(SUM("Market Cap")           AS BIGINT), 0) AS "Market Cap",
                ROUND(CAST(SUM("CQ Total Assets")      AS BIGINT), 0) AS Assets,
                ROUND(CAST(SUM("CQ Total Liabilities") AS BIGINT), 0) AS Liabilities,
                ROUND(CAST(SUM("CQ Equity")            AS BIGINT), 0) AS Equity,
                ROUND(CAST(SUM("TTM Revenue")          AS BIGINT), 0) AS Revenue,
                ROUND(CAST(SUM("TTM Income")           AS BIGINT), 0) AS Income,
                ROUND(CAST(AVG("RSI20")                AS DOUBLE), 0) AS RSI20,
                ROUND(CAST(AVG("RSI60")                AS DOUBLE), 0) AS RSI60,
                ROUND(CAST(AVG("RSI240")               AS DOUBLE), 0) AS RSI240,
                ROUND((COUNT(*) FILTER (WHERE Close > MA20) / COUNT(*) * 100), 2)  AS "MA20 Breadth",
                ROUND((COUNT(*) FILTER (WHERE Close > MA60) / COUNT(*) * 100), 2)  AS "MA60 Breadth",
                ROUND((COUNT(*) FILTER (WHERE Close > MA240) / COUNT(*) * 100), 2) AS "MA240 Breadth",
                SUM("CY Revenue") AS "CY Revenue",
                SUM("CY Income")  AS "CY Income"
            FROM df_meta
            WHERE Sector != 'ETF'
        ),
        sector_industry_agg AS (
            SELECT Sector, Industry, COUNT(*) AS Count,
                ROUND(CAST(SUM("Value")                AS BIGINT), 0) AS Turnover,
                ROUND(CAST(SUM("Market Cap")           AS BIGINT), 0) AS "Market Cap",
                ROUND(CAST(SUM("CQ Total Assets")      AS BIGINT), 0) AS Assets,
                ROUND(CAST(SUM("CQ Total Liabilities") AS BIGINT), 0) AS Liabilities,
                ROUND(CAST(SUM("CQ Equity")            AS BIGINT), 0) AS Equity,
                ROUND(CAST(SUM("TTM Revenue")          AS BIGINT), 0) AS Revenue,
                ROUND(CAST(SUM("TTM Income")           AS BIGINT), 0) AS Income,
                ROUND(CAST(AVG("RSI20")                AS DOUBLE), 0) AS RSI20,
                ROUND(CAST(AVG("RSI60")                AS DOUBLE), 0) AS RSI60,
                ROUND(CAST(AVG("RSI240")               AS DOUBLE), 0) AS RSI240,
                ROUND((COUNT(*) FILTER (WHERE Close > MA20) / COUNT(*) * 100), 2)  AS "MA20 Breadth",
                ROUND((COUNT(*) FILTER (WHERE Close > MA60) / COUNT(*) * 100), 2)  AS "MA60 Breadth",
                ROUND((COUNT(*) FILTER (WHERE Close > MA240) / COUNT(*) * 100), 2) AS "MA240 Breadth",
                SUM("CY Revenue") AS "CY Revenue",
                SUM("CY Income")  AS "CY Income"
            FROM df_meta
            WHERE Sector != 'ETF'
            GROUP BY Sector, Industry
        )
        SELECT * FROM market_agg
        UNION ALL
        SELECT * FROM sector_industry_agg
    ),
    aggs AS (
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
             FROM pre_agg
        )
        SELECT *,
            ROUND("P/S" / NULLIF("Revenue Growth", 0), 2) AS "PS/G",
            ROUND("P/E" / NULLIF("Income Growth" , 0), 2) AS "PE/G"
        FROM ratios
    ),
    ranks AS (
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
            FROM aggs
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
    )
    SELECT *, 
        ROUND(("Profitability Rank" + 
        "Valuation Rank" + 
        "Breadth Rank") / 3, 2) AS "Overall Score"
    FROM ranks
    ORDER BY "Overall Score" ASC
""").fetchdf()

df_agg.to_parquet('pse_clean_agg.parquet', index=False)

with open('pse_clean_agg.parquet', 'rb') as f:
    client.storage.from_("pse-clean").upload(
        'pse_clean_agg.parquet',
        f,
        {"upsert": "true"}
    )