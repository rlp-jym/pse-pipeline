{{ config(
    materialized='table',
    post_hook=[
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.parquet'",
        "COPY {{ this }} TO 's3://pse-clean/{{ this.name }}.csv' (FORMAT CSV, HEADER)"
    ]
) }}

SELECT
    Symbol, Name, Description, Sector, Industry, FiscalYearEnd
	--------------------------------------------------
    , TRY_CAST(ROUND(MarketCap, 0) AS BIGINT) AS MarketCap
    , TRY_CAST(ROUND(FloatPct,  2) AS DOUBLE) AS FloatPct
	--------------------------------------------------
    , TRY_CAST(ROUND(CYAssetsCurrent,      0) AS BIGINT) AS CYAssetsCurrent
    , TRY_CAST(ROUND(CYAssetsTotal,        0) AS BIGINT) AS CYAssetsTotal
    , TRY_CAST(ROUND(CYLiabilitiesCurrent, 0) AS BIGINT) AS CYLiabilitiesCurrent
    , TRY_CAST(ROUND(CYLiabilitiesTotal,   0) AS BIGINT) AS CYLiabilitiesTotal
    , TRY_CAST(ROUND(CYRetainedEarnings,   0) AS BIGINT) AS CYRetainedEarnings
    , TRY_CAST(ROUND(CYEquity,  0) AS BIGINT) AS CYEquity
    , TRY_CAST(ROUND(CYRevenue, 0) AS BIGINT) AS CYRevenue
    , TRY_CAST(ROUND(CYIncome,  0) AS BIGINT) AS CYIncome
    , TRY_CAST(ROUND(CYBVPS,    4) AS DOUBLE) AS CYBVPS
	, TRY_CAST(ROUND(CYEPS,     4) AS DOUBLE) AS CYEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(CQAssetsCurrent,      0) AS BIGINT) AS CQAssetsCurrent
    , TRY_CAST(ROUND(CQAssetsTotal,        0) AS BIGINT) AS CQAssetsTotal
    , TRY_CAST(ROUND(CQLiabilitiesCurrent, 0) AS BIGINT) AS CQLiabilitiesCurrent
    , TRY_CAST(ROUND(CQLiabilitiesTotal,   0) AS BIGINT) AS CQLiabilitiesTotal
    , TRY_CAST(ROUND(CQRetainedEarnings,   0) AS BIGINT) AS CQRetainedEarnings
    , TRY_CAST(ROUND(CQEquity,  0) AS BIGINT) AS CQEquity
    , TRY_CAST(ROUND(CQRevenue, 0) AS BIGINT) AS CQRevenue
    , TRY_CAST(ROUND(CQIncome,  0) AS BIGINT) AS CQIncome
    , TRY_CAST(ROUND(CQBVPS,    4) AS DOUBLE) AS CQBVPS
	, TRY_CAST(ROUND(CQEPS,     4) AS DOUBLE) AS CQEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(CYytdRevenue, 0) AS BIGINT) AS CYytdRevenue
    , TRY_CAST(ROUND(CYytdIncome,  0) AS BIGINT) AS CYytdIncome
    , TRY_CAST(ROUND(CYytdEPS,     4) AS DOUBLE) AS CYytdEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(TTMRevenue, 0) AS BIGINT) AS TTMRevenue
    , TRY_CAST(ROUND(TTMIncome,  0) AS BIGINT) AS TTMIncome
    , TRY_CAST(ROUND(TTMEPS,     4) AS DOUBLE) AS TTMEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(GrowthRevenue,  2) AS DOUBLE) AS GrowthRevenue
    , TRY_CAST(ROUND(GrowthIncome,   2) AS DOUBLE) AS GrowthIncome
    , TRY_CAST(ROUND(GrowthEPS,      2) AS DOUBLE) AS GrowthEPS
    , TRY_CAST(ROUND(MarginIncome,   2) AS DOUBLE) AS MarginIncome
    , TRY_CAST(ROUND(ReturnOnAssets, 2) AS DOUBLE) AS ReturnOnAssets
    , TRY_CAST(ROUND(ReturnOnEquity, 2) AS DOUBLE) AS ReturnOnEquity
	--------------------------------------------------
    , TRY_CAST(ROUND(CurrentRatio,           2) AS DOUBLE) AS CurrentRatio
    , TRY_CAST(ROUND(LiabilitiesAssetsRatio, 2) AS DOUBLE) AS LiabilitiesAssetsRatio
    , TRY_CAST(ROUND(LiabilitiesEquityRatio, 2) AS DOUBLE) AS LiabilitiesEquityRatio
    , TRY_CAST(ROUND(PSRatio,  2) AS DOUBLE) AS PSRatio
    , TRY_CAST(ROUND(PERatio,  2) AS DOUBLE) AS PERatio
    , TRY_CAST(ROUND(PSGRatio, 2) AS DOUBLE) AS PSGRatio
    , TRY_CAST(ROUND(PEGRatio, 2) AS DOUBLE) AS PEGRatio
    , TRY_CAST(ROUND(PBVRatio, 2) AS DOUBLE) AS PBVRatio
	--------------------------------------------------
    , TRY_CAST(ROUND(Close,  2) AS DOUBLE) AS Close
    , TRY_CAST(ROUND(Chg,    2) AS DOUBLE) AS Chg
    , TRY_CAST(ROUND(Value,  0) AS BIGINT) AS Value
    , TRY_CAST(ROUND(Volume, 0) AS BIGINT) AS Volume
	--------------------------------------------------
    , TRY_CAST(ROUND(MA5,   2) AS DOUBLE) AS MA5
	, TRY_CAST(ROUND(MA10,  2) AS DOUBLE) AS MA10
	, TRY_CAST(ROUND(MA20,  2) AS DOUBLE) AS MA20
	, TRY_CAST(ROUND(MA30,  2) AS DOUBLE) AS MA30
    , TRY_CAST(ROUND(MA60,  2) AS DOUBLE) AS MA60
    , TRY_CAST(ROUND(MA240, 2) AS DOUBLE) AS MA240
	--------------------------------------------------
    , TRY_CAST(ROUND(RSI5,   2) AS DOUBLE) AS RSI5
	, TRY_CAST(ROUND(RSI10,  2) AS DOUBLE) AS RSI10
	, TRY_CAST(ROUND(RSI20,  2) AS DOUBLE) AS RSI20
	, TRY_CAST(ROUND(RSI30,  2) AS DOUBLE) AS RSI30
    , TRY_CAST(ROUND(RSI60,  2) AS DOUBLE) AS RSI60
    , TRY_CAST(ROUND(RSI240, 2) AS DOUBLE) AS RSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(High5,   2) AS DOUBLE) AS High5
	, TRY_CAST(ROUND(High10,  2) AS DOUBLE) AS High10
	, TRY_CAST(ROUND(High20,  2) AS DOUBLE) AS High20
	, TRY_CAST(ROUND(High30,  2) AS DOUBLE) AS High30
    , TRY_CAST(ROUND(High60,  2) AS DOUBLE) AS High60
	, TRY_CAST(ROUND(High240, 2) AS DOUBLE) AS High240
    , TRY_CAST(ROUND(HighAll, 2) AS DOUBLE) AS HighAll
	--------------------------------------------------
    , TRY_CAST(ROUND(Low5,   2) AS DOUBLE) AS Low5
	, TRY_CAST(ROUND(Low10,  2) AS DOUBLE) AS Low10
	, TRY_CAST(ROUND(Low20,  2) AS DOUBLE) AS Low20
	, TRY_CAST(ROUND(Low30,  2) AS DOUBLE) AS Low30
    , TRY_CAST(ROUND(Low60,  2) AS DOUBLE) AS Low60
	, TRY_CAST(ROUND(Low240, 2) AS DOUBLE) AS Low240
    , TRY_CAST(ROUND(LowAll, 2) AS DOUBLE) AS LowAll
	--------------------------------------------------
    , TRY_CAST(ROUND(MarketRSI5,   2) AS DOUBLE) AS MarketRSI5
	, TRY_CAST(ROUND(MarketRSI10,  2) AS DOUBLE) AS MarketRSI10
	, TRY_CAST(ROUND(MarketRSI20,  2) AS DOUBLE) AS MarketRSI20
	, TRY_CAST(ROUND(MarketRSI30,  2) AS DOUBLE) AS MarketRSI30
    , TRY_CAST(ROUND(MarketRSI60,  2) AS DOUBLE) AS MarketRSI60
    , TRY_CAST(ROUND(MarketRSI240, 2) AS DOUBLE) AS MarketRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(SectorRSI5,   2) AS DOUBLE) AS SectorRSI5
	, TRY_CAST(ROUND(SectorRSI10,  2) AS DOUBLE) AS SectorRSI10
	, TRY_CAST(ROUND(SectorRSI20,  2) AS DOUBLE) AS SectorRSI20
	, TRY_CAST(ROUND(SectorRSI30,  2) AS DOUBLE) AS SectorRSI30
    , TRY_CAST(ROUND(SectorRSI60,  2) AS DOUBLE) AS SectorRSI60
    , TRY_CAST(ROUND(SectorRSI240, 2) AS DOUBLE) AS SectorRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(IndustryRSI5,   2) AS DOUBLE) AS IndustryRSI5
	, TRY_CAST(ROUND(IndustryRSI10,  2) AS DOUBLE) AS IndustryRSI10
	, TRY_CAST(ROUND(IndustryRSI20,  2) AS DOUBLE) AS IndustryRSI20
	, TRY_CAST(ROUND(IndustryRSI30,  2) AS DOUBLE) AS IndustryRSI30
    , TRY_CAST(ROUND(IndustryRSI60,  2) AS DOUBLE) AS IndustryRSI60
    , TRY_CAST(ROUND(IndustryRSI240, 2) AS DOUBLE) AS IndustryRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeHigh5,   2) AS DOUBLE) AS RelativeHigh5
	, TRY_CAST(ROUND(RelativeHigh10,  2) AS DOUBLE) AS RelativeHigh10
	, TRY_CAST(ROUND(RelativeHigh20,  2) AS DOUBLE) AS RelativeHigh20
	, TRY_CAST(ROUND(RelativeHigh30,  2) AS DOUBLE) AS RelativeHigh30
    , TRY_CAST(ROUND(RelativeHigh60,  2) AS DOUBLE) AS RelativeHigh60
    , TRY_CAST(ROUND(RelativeHigh240, 2) AS DOUBLE) AS RelativeHigh240
    , TRY_CAST(ROUND(RelativeHighAll, 2) AS DOUBLE) AS RelativeHighAll
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeLow5,   2) AS DOUBLE) AS RelativeLow5
	, TRY_CAST(ROUND(RelativeLow10,  2) AS DOUBLE) AS RelativeLow10
	, TRY_CAST(ROUND(RelativeLow20,  2) AS DOUBLE) AS RelativeLow20
	, TRY_CAST(ROUND(RelativeLow30,  2) AS DOUBLE) AS RelativeLow30
    , TRY_CAST(ROUND(RelativeLow60,  2) AS DOUBLE) AS RelativeLow60
    , TRY_CAST(ROUND(RelativeLow240, 2) AS DOUBLE) AS RelativeLow240
    , TRY_CAST(ROUND(RelativeLowAll, 2) AS DOUBLE) AS RelativeLowAll
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeMarketRSI5,   2) AS DOUBLE) AS RelativeMarketRSI5
	, TRY_CAST(ROUND(RelativeMarketRSI10,  2) AS DOUBLE) AS RelativeMarketRSI10
	, TRY_CAST(ROUND(RelativeMarketRSI20,  2) AS DOUBLE) AS RelativeMarketRSI20
	, TRY_CAST(ROUND(RelativeMarketRSI30,  2) AS DOUBLE) AS RelativeMarketRSI30
    , TRY_CAST(ROUND(RelativeMarketRSI60,  2) AS DOUBLE) AS RelativeMarketRSI60
    , TRY_CAST(ROUND(RelativeMarketRSI240, 2) AS DOUBLE) AS RelativeMarketRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeSectorRSI5,   2) AS DOUBLE) AS RelativeSectorRSI5
	, TRY_CAST(ROUND(RelativeSectorRSI10,  2) AS DOUBLE) AS RelativeSectorRSI10
	, TRY_CAST(ROUND(RelativeSectorRSI20,  2) AS DOUBLE) AS RelativeSectorRSI20
	, TRY_CAST(ROUND(RelativeSectorRSI30,  2) AS DOUBLE) AS RelativeSectorRSI30
    , TRY_CAST(ROUND(RelativeSectorRSI60,  2) AS DOUBLE) AS RelativeSectorRSI60
    , TRY_CAST(ROUND(RelativeSectorRSI240, 2) AS DOUBLE) AS RelativeSectorRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeIndustryRSI5,   2) AS DOUBLE) AS RelativeIndustryRSI5
	, TRY_CAST(ROUND(RelativeIndustryRSI10,  2) AS DOUBLE) AS RelativeIndustryRSI10
	, TRY_CAST(ROUND(RelativeIndustryRSI20,  2) AS DOUBLE) AS RelativeIndustryRSI20
	, TRY_CAST(ROUND(RelativeIndustryRSI30,  2) AS DOUBLE) AS RelativeIndustryRSI30
    , TRY_CAST(ROUND(RelativeIndustryRSI60,  2) AS DOUBLE) AS RelativeIndustryRSI60
    , TRY_CAST(ROUND(RelativeIndustryRSI240, 2) AS DOUBLE) AS RelativeIndustryRSI240
	--------------------------------------------------
	, CASE
		WHEN High5 == HighAll THEN 'All Time High'
		WHEN High5 == High240 THEN 'Year High'
		WHEN High5 == High60  THEN 'Quarter High'
		WHEN High5 == High20  THEN 'Month High'
			ELSE '' END AS AlertsBreakout
	, CASE
		WHEN Low5 == LowAll THEN 'All Time Low'
		WHEN Low5 == Low240 THEN 'Year Low'
		WHEN Low5 == Low60  THEN 'Quarter Low'
		WHEN Low5 == Low20  THEN 'Month Low'
			ELSE '' END AS AlertsBreakdown
	, CASE
		WHEN RSI10 < 10 THEN 'Panic'
		WHEN RSI10 < 20 THEN 'Oversold'
		WHEN RSI10 > 90 THEN 'Euphoric'
		WHEN RSI10 > 80 THEN 'Overbought'
			ELSE '' END AS AlertsBehavioral

FROM {{ ref('compute_ratios') }}
ORDER BY MarketCap DESC