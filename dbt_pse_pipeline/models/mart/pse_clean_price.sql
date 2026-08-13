{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT
    TRY_CAST(Date AS DATE) AS Date
    , Symbol, Sector, Industry
    --------------------------------------------------
	, TRY_CAST(Open  AS NUMERIC) AS Open
    , TRY_CAST(High  AS NUMERIC) AS High
    , TRY_CAST(Low   AS NUMERIC) AS Low
    , TRY_CAST(Close AS NUMERIC) AS Close
    , TRY_CAST(Chg   AS NUMERIC) AS Chg
    , TRY_CAST(ROUND(Value,  0) AS BIGINT) AS Value
    , TRY_CAST(ROUND(Volume, 0) AS BIGINT) AS Volume
    --------------------------------------------------
	, TRY_CAST(ROUND(MA5,   2)  AS NUMERIC) AS MA5
	, TRY_CAST(ROUND(MA10,  2)  AS NUMERIC) AS MA10
	, TRY_CAST(ROUND(MA20,  2)  AS NUMERIC) AS MA20
	, TRY_CAST(ROUND(MA30,  2)  AS NUMERIC) AS MA30
    , TRY_CAST(ROUND(MA60,  2)  AS NUMERIC) AS MA60
    , TRY_CAST(ROUND(MA240, 2)  AS NUMERIC) AS MA240
	--------------------------------------------------
	, TRY_CAST(ROUND(RSI5,   2) AS NUMERIC) AS RSI5
    , TRY_CAST(ROUND(RSI10,  2) AS NUMERIC) AS RSI10
	, TRY_CAST(ROUND(RSI20,  2) AS NUMERIC) AS RSI20
	, TRY_CAST(ROUND(RSI30,  2) AS NUMERIC) AS RSI30
    , TRY_CAST(ROUND(RSI60,  2) AS NUMERIC) AS RSI60
    , TRY_CAST(ROUND(RSI240, 2) AS NUMERIC) AS RSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(High5,   2) AS NUMERIC) AS High5
    , TRY_CAST(ROUND(High10,  2) AS NUMERIC) AS High10
	, TRY_CAST(ROUND(High20,  2) AS NUMERIC) AS High20
	, TRY_CAST(ROUND(High30,  2) AS NUMERIC) AS High30
	, TRY_CAST(ROUND(High60,  2) AS NUMERIC) AS High60
    , TRY_CAST(ROUND(High240, 2) AS NUMERIC) AS High240
    , TRY_CAST(ROUND(HighAll, 2) AS NUMERIC) AS HighAll
    --------------------------------------------------
	, TRY_CAST(ROUND(Low5,    2) AS NUMERIC) AS Low5
	, TRY_CAST(ROUND(Low10,   2) AS NUMERIC) AS Low10
	, TRY_CAST(ROUND(Low20,   2) AS NUMERIC) AS Low20
	, TRY_CAST(ROUND(Low30,   2) AS NUMERIC) AS Low30
    , TRY_CAST(ROUND(Low60,   2) AS NUMERIC) AS Low60
    , TRY_CAST(ROUND(Low240,  2) AS NUMERIC) AS Low240
    , TRY_CAST(ROUND(LowAll,  2) AS NUMERIC) AS LowAll
    --------------------------------------------------
	, TRY_CAST(ROUND(MarketRSI5,   2) AS NUMERIC) AS MarketRSI5
	, TRY_CAST(ROUND(MarketRSI10,  2) AS NUMERIC) AS MarketRSI10
	, TRY_CAST(ROUND(MarketRSI20,  2) AS NUMERIC) AS MarketRSI20
	, TRY_CAST(ROUND(MarketRSI30,  2) AS NUMERIC) AS MarketRSI30
    , TRY_CAST(ROUND(MarketRSI60,  2) AS NUMERIC) AS MarketRSI60
    , TRY_CAST(ROUND(MarketRSI240, 2) AS NUMERIC) AS MarketRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(SectorRSI5,   2) AS NUMERIC) AS SectorRSI5
	, TRY_CAST(ROUND(SectorRSI10,  2) AS NUMERIC) AS SectorRSI10
	, TRY_CAST(ROUND(SectorRSI20,  2) AS NUMERIC) AS SectorRSI20
	, TRY_CAST(ROUND(SectorRSI30,  2) AS NUMERIC) AS SectorRSI30
    , TRY_CAST(ROUND(SectorRSI60,  2) AS NUMERIC) AS SectorRSI60
    , TRY_CAST(ROUND(SectorRSI240, 2) AS NUMERIC) AS SectorRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(IndustryRSI5,   2) AS NUMERIC) AS IndustryRSI5
	, TRY_CAST(ROUND(IndustryRSI10,  2) AS NUMERIC) AS IndustryRSI10
	, TRY_CAST(ROUND(IndustryRSI20,  2) AS NUMERIC) AS IndustryRSI20
	, TRY_CAST(ROUND(IndustryRSI30,  2) AS NUMERIC) AS IndustryRSI30
    , TRY_CAST(ROUND(IndustryRSI60,  2) AS NUMERIC) AS IndustryRSI60
    , TRY_CAST(ROUND(IndustryRSI240, 2) AS NUMERIC) AS IndustryRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeHigh5,   2) AS NUMERIC) AS RelativeHigh5
    , TRY_CAST(ROUND(RelativeHigh10,  2) AS NUMERIC) AS RelativeHigh10
    , TRY_CAST(ROUND(RelativeHigh20,  2) AS NUMERIC) AS RelativeHigh20
    , TRY_CAST(ROUND(RelativeHigh30,  2) AS NUMERIC) AS RelativeHigh30
	, TRY_CAST(ROUND(RelativeHigh60,  2) AS NUMERIC) AS RelativeHigh60
	, TRY_CAST(ROUND(RelativeHigh240, 2) AS NUMERIC) AS RelativeHigh240
	, TRY_CAST(ROUND(RelativeHighAll, 2) AS NUMERIC) AS RelativeHighAll
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeLow5,   2) AS NUMERIC) AS RelativeLow5
    , TRY_CAST(ROUND(RelativeLow10,  2) AS NUMERIC) AS RelativeLow10
    , TRY_CAST(ROUND(RelativeLow20,  2) AS NUMERIC) AS RelativeLow20
    , TRY_CAST(ROUND(RelativeLow30,  2) AS NUMERIC) AS RelativeLow30
	, TRY_CAST(ROUND(RelativeLow60,  2) AS NUMERIC) AS RelativeLow60
	, TRY_CAST(ROUND(RelativeLow240, 2) AS NUMERIC) AS RelativeLow240
	, TRY_CAST(ROUND(RelativeLowAll, 2) AS NUMERIC) AS RelativeLowAll
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeMarketRSI5,   2) AS NUMERIC) AS RelativeMarketRSI5
	, TRY_CAST(ROUND(RelativeMarketRSI10,  2) AS NUMERIC) AS RelativeMarketRSI10
	, TRY_CAST(ROUND(RelativeMarketRSI20,  2) AS NUMERIC) AS RelativeMarketRSI20
	, TRY_CAST(ROUND(RelativeMarketRSI30,  2) AS NUMERIC) AS RelativeMarketRSI30
    , TRY_CAST(ROUND(RelativeMarketRSI60,  2) AS NUMERIC) AS RelativeMarketRSI60
    , TRY_CAST(ROUND(RelativeMarketRSI240, 2) AS NUMERIC) AS RelativeMarketRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeSectorRSI5,   2) AS NUMERIC) AS RelativeSectorRSI5
	, TRY_CAST(ROUND(RelativeSectorRSI10,  2) AS NUMERIC) AS RelativeSectorRSI10
	, TRY_CAST(ROUND(RelativeSectorRSI20,  2) AS NUMERIC) AS RelativeSectorRSI20
	, TRY_CAST(ROUND(RelativeSectorRSI30,  2) AS NUMERIC) AS RelativeSectorRSI30
    , TRY_CAST(ROUND(RelativeSectorRSI60,  2) AS NUMERIC) AS RelativeSectorRSI60
    , TRY_CAST(ROUND(RelativeSectorRSI240, 2) AS NUMERIC) AS RelativeSectorRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeIndustryRSI5,   2) AS NUMERIC) AS RelativeIndustryRSI5
	, TRY_CAST(ROUND(RelativeIndustryRSI10,  2) AS NUMERIC) AS RelativeIndustryRSI10
	, TRY_CAST(ROUND(RelativeIndustryRSI20,  2) AS NUMERIC) AS RelativeIndustryRSI20
	, TRY_CAST(ROUND(RelativeIndustryRSI30,  2) AS NUMERIC) AS RelativeIndustryRSI30
    , TRY_CAST(ROUND(RelativeIndustryRSI60,  2) AS NUMERIC) AS RelativeIndustryRSI60
    , TRY_CAST(ROUND(RelativeIndustryRSI240, 2) AS NUMERIC) AS RelativeIndustryRSI240

FROM {{ ref('pse_clean_price_full') }}
WHERE YEAR(Date) = 2026