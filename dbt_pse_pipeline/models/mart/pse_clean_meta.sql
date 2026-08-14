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
    , TRY_CAST(ROUND(FloatPct,  2) AS NUMERIC) AS FloatPct
	--------------------------------------------------
    , TRY_CAST(ROUND(CYAssetsCurrent,      0) AS BIGINT) AS CYAssetsCurrent
    , TRY_CAST(ROUND(CYAssetsTotal,        0) AS BIGINT) AS CYAssetsTotal
    , TRY_CAST(ROUND(CYLiabilitiesCurrent, 0) AS BIGINT) AS CYLiabilitiesCurrent
    , TRY_CAST(ROUND(CYLiabilitiesTotal,   0) AS BIGINT) AS CYLiabilitiesTotal
    , TRY_CAST(ROUND(CYRetainedEarnings,   0) AS BIGINT) AS CYRetainedEarnings
    , TRY_CAST(ROUND(CYEquity,  0) AS BIGINT) AS CYEquity
    , TRY_CAST(ROUND(CYRevenue, 0) AS BIGINT) AS CYRevenue
    , TRY_CAST(ROUND(CYIncome,  0) AS BIGINT) AS CYIncome
    , TRY_CAST(ROUND(CYBVPS,    4) AS NUMERIC) AS CYBVPS
	, TRY_CAST(ROUND(CYEPS,     4) AS NUMERIC) AS CYEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(CQAssetsCurrent,      0) AS BIGINT) AS CQAssetsCurrent
    , TRY_CAST(ROUND(CQAssetsTotal,        0) AS BIGINT) AS CQAssetsTotal
    , TRY_CAST(ROUND(CQLiabilitiesCurrent, 0) AS BIGINT) AS CQLiabilitiesCurrent
    , TRY_CAST(ROUND(CQLiabilitiesTotal,   0) AS BIGINT) AS CQLiabilitiesTotal
    , TRY_CAST(ROUND(CQRetainedEarnings,   0) AS BIGINT) AS CQRetainedEarnings
    , TRY_CAST(ROUND(CQEquity,  0) AS BIGINT) AS CQEquity
    , TRY_CAST(ROUND(CQRevenue, 0) AS BIGINT) AS CQRevenue
    , TRY_CAST(ROUND(CQIncome,  0) AS BIGINT) AS CQIncome
    , TRY_CAST(ROUND(CQBVPS,    4) AS NUMERIC) AS CQBVPS
	, TRY_CAST(ROUND(CQEPS,     4) AS NUMERIC) AS CQEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(CYytdRevenue, 0) AS BIGINT) AS CYytdRevenue
    , TRY_CAST(ROUND(CYytdIncome,  0) AS BIGINT) AS CYytdIncome
    , TRY_CAST(ROUND(CYytdEPS,     4) AS NUMERIC) AS CYytdEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(TTMRevenue, 0) AS BIGINT) AS TTMRevenue
    , TRY_CAST(ROUND(TTMIncome,  0) AS BIGINT) AS TTMIncome
    , TRY_CAST(ROUND(TTMEPS,     4) AS NUMERIC) AS TTMEPS
	--------------------------------------------------
    , TRY_CAST(ROUND(GrowthRevenue,  2) AS NUMERIC) AS GrowthRevenue
    , TRY_CAST(ROUND(GrowthIncome,   2) AS NUMERIC) AS GrowthIncome
    , TRY_CAST(ROUND(GrowthEPS,      2) AS NUMERIC) AS GrowthEPS
    , TRY_CAST(ROUND(MarginIncome,   2) AS NUMERIC) AS MarginIncome
    , TRY_CAST(ROUND(ReturnOnAssets, 2) AS NUMERIC) AS ReturnOnAssets
    , TRY_CAST(ROUND(ReturnOnEquity, 2) AS NUMERIC) AS ReturnOnEquity
	--------------------------------------------------
    , TRY_CAST(ROUND(CurrentRatio,           2) AS NUMERIC) AS CurrentRatio
    , TRY_CAST(ROUND(LiabilitiesAssetsRatio, 2) AS NUMERIC) AS LiabilitiesAssetsRatio
    , TRY_CAST(ROUND(LiabilitiesEquityRatio, 2) AS NUMERIC) AS LiabilitiesEquityRatio
    , TRY_CAST(ROUND(PSRatio,  2) AS NUMERIC) AS PSRatio
    , TRY_CAST(ROUND(PERatio,  2) AS NUMERIC) AS PERatio
    , TRY_CAST(ROUND(PSGRatio, 2) AS NUMERIC) AS PSGRatio
    , TRY_CAST(ROUND(PEGRatio, 2) AS NUMERIC) AS PEGRatio
    , TRY_CAST(ROUND(PBVRatio, 2) AS NUMERIC) AS PBVRatio
	--------------------------------------------------
    , TRY_CAST(ROUND(Close,  2) AS NUMERIC) AS Close
    , TRY_CAST(ROUND(Chg,    2) AS NUMERIC) AS Chg
    , TRY_CAST(ROUND(Value,  0) AS BIGINT) AS Value
    , TRY_CAST(ROUND(Volume, 0) AS BIGINT) AS Volume
	--------------------------------------------------
    , TRY_CAST(ROUND(MA5,   2) AS NUMERIC) AS MA5
	, TRY_CAST(ROUND(MA10,  2) AS NUMERIC) AS MA10
	, TRY_CAST(ROUND(MA20,  2) AS NUMERIC) AS MA20
	, TRY_CAST(ROUND(MA30,  2) AS NUMERIC) AS MA30
    , TRY_CAST(ROUND(MA60,  2) AS NUMERIC) AS MA60
    , TRY_CAST(ROUND(MA120, 2) AS NUMERIC) AS MA120
	, TRY_CAST(ROUND(MA240, 2) AS NUMERIC) AS MA240
	--------------------------------------------------
    , TRY_CAST(ROUND(RSI5,   2) AS NUMERIC) AS RSI5
	, TRY_CAST(ROUND(RSI10,  2) AS NUMERIC) AS RSI10
	, TRY_CAST(ROUND(RSI20,  2) AS NUMERIC) AS RSI20
	, TRY_CAST(ROUND(RSI30,  2) AS NUMERIC) AS RSI30
    , TRY_CAST(ROUND(RSI60,  2) AS NUMERIC) AS RSI60
	, TRY_CAST(ROUND(RSI120, 2) AS NUMERIC) AS RSI120
    , TRY_CAST(ROUND(RSI240, 2) AS NUMERIC) AS RSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(High5,   2) AS NUMERIC) AS High5
	, TRY_CAST(ROUND(High10,  2) AS NUMERIC) AS High10
	, TRY_CAST(ROUND(High20,  2) AS NUMERIC) AS High20
	, TRY_CAST(ROUND(High30,  2) AS NUMERIC) AS High30
    , TRY_CAST(ROUND(High60,  2) AS NUMERIC) AS High60
	, TRY_CAST(ROUND(High120, 2) AS NUMERIC) AS High120
	, TRY_CAST(ROUND(High240, 2) AS NUMERIC) AS High240
    , TRY_CAST(ROUND(HighAll, 2) AS NUMERIC) AS HighAll
	--------------------------------------------------
    , TRY_CAST(ROUND(Low5,   2) AS NUMERIC) AS Low5
	, TRY_CAST(ROUND(Low10,  2) AS NUMERIC) AS Low10
	, TRY_CAST(ROUND(Low20,  2) AS NUMERIC) AS Low20
	, TRY_CAST(ROUND(Low30,  2) AS NUMERIC) AS Low30
    , TRY_CAST(ROUND(Low60,  2) AS NUMERIC) AS Low60
	, TRY_CAST(ROUND(Low120, 2) AS NUMERIC) AS Low120
	, TRY_CAST(ROUND(Low240, 2) AS NUMERIC) AS Low240
    , TRY_CAST(ROUND(LowAll, 2) AS NUMERIC) AS LowAll
	--------------------------------------------------
    , TRY_CAST(ROUND(MarketRSI5,   2) AS NUMERIC) AS MarketRSI5
	, TRY_CAST(ROUND(MarketRSI10,  2) AS NUMERIC) AS MarketRSI10
	, TRY_CAST(ROUND(MarketRSI20,  2) AS NUMERIC) AS MarketRSI20
	, TRY_CAST(ROUND(MarketRSI30,  2) AS NUMERIC) AS MarketRSI30
    , TRY_CAST(ROUND(MarketRSI60,  2) AS NUMERIC) AS MarketRSI60
    , TRY_CAST(ROUND(MarketRSI120, 2) AS NUMERIC) AS MarketRSI120
	, TRY_CAST(ROUND(MarketRSI240, 2) AS NUMERIC) AS MarketRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(SectorRSI5,   2) AS NUMERIC) AS SectorRSI5
	, TRY_CAST(ROUND(SectorRSI10,  2) AS NUMERIC) AS SectorRSI10
	, TRY_CAST(ROUND(SectorRSI20,  2) AS NUMERIC) AS SectorRSI20
	, TRY_CAST(ROUND(SectorRSI30,  2) AS NUMERIC) AS SectorRSI30
    , TRY_CAST(ROUND(SectorRSI60,  2) AS NUMERIC) AS SectorRSI60
    , TRY_CAST(ROUND(SectorRSI120, 2) AS NUMERIC) AS SectorRSI120
	, TRY_CAST(ROUND(SectorRSI240, 2) AS NUMERIC) AS SectorRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(IndustryRSI5,   2) AS NUMERIC) AS IndustryRSI5
	, TRY_CAST(ROUND(IndustryRSI10,  2) AS NUMERIC) AS IndustryRSI10
	, TRY_CAST(ROUND(IndustryRSI20,  2) AS NUMERIC) AS IndustryRSI20
	, TRY_CAST(ROUND(IndustryRSI30,  2) AS NUMERIC) AS IndustryRSI30
    , TRY_CAST(ROUND(IndustryRSI60,  2) AS NUMERIC) AS IndustryRSI60
    , TRY_CAST(ROUND(IndustryRSI120, 2) AS NUMERIC) AS IndustryRSI120
	, TRY_CAST(ROUND(IndustryRSI240, 2) AS NUMERIC) AS IndustryRSI240
	--------------------------------------------------
    , TRY_CAST(ROUND(RelativeHigh5,   2) AS NUMERIC) AS RelativeHigh5
	, TRY_CAST(ROUND(RelativeHigh10,  2) AS NUMERIC) AS RelativeHigh10
	, TRY_CAST(ROUND(RelativeHigh20,  2) AS NUMERIC) AS RelativeHigh20
	, TRY_CAST(ROUND(RelativeHigh30,  2) AS NUMERIC) AS RelativeHigh30
    , TRY_CAST(ROUND(RelativeHigh60,  2) AS NUMERIC) AS RelativeHigh60
    , TRY_CAST(ROUND(RelativeHigh120, 2) AS NUMERIC) AS RelativeHigh120
	, TRY_CAST(ROUND(RelativeHigh240, 2) AS NUMERIC) AS RelativeHigh240
    , TRY_CAST(ROUND(RelativeHighAll, 2) AS NUMERIC) AS RelativeHighAll
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeLow5,   2) AS NUMERIC) AS RelativeLow5
	, TRY_CAST(ROUND(RelativeLow10,  2) AS NUMERIC) AS RelativeLow10
	, TRY_CAST(ROUND(RelativeLow20,  2) AS NUMERIC) AS RelativeLow20
	, TRY_CAST(ROUND(RelativeLow30,  2) AS NUMERIC) AS RelativeLow30
    , TRY_CAST(ROUND(RelativeLow60,  2) AS NUMERIC) AS RelativeLow60
    , TRY_CAST(ROUND(RelativeLow120, 2) AS NUMERIC) AS RelativeLow120
	, TRY_CAST(ROUND(RelativeLow240, 2) AS NUMERIC) AS RelativeLow240
    , TRY_CAST(ROUND(RelativeLowAll, 2) AS NUMERIC) AS RelativeLowAll
		--------------------------------------------------
	, TRY_CAST(ROUND(RelativeVolatility5,   2) AS NUMERIC) AS RelativeVolatility5
	, TRY_CAST(ROUND(RelativeVolatility20,  2) AS NUMERIC) AS RelativeVolatility20
	, TRY_CAST(ROUND(RelativeVolatility60,  2) AS NUMERIC) AS RelativeVolatility60
	, TRY_CAST(ROUND(RelativeVolatility240, 2) AS NUMERIC) AS RelativeVolatility240
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeMarketRSI5,   2) AS NUMERIC) AS RelativeMarketRSI5
	, TRY_CAST(ROUND(RelativeMarketRSI10,  2) AS NUMERIC) AS RelativeMarketRSI10
	, TRY_CAST(ROUND(RelativeMarketRSI20,  2) AS NUMERIC) AS RelativeMarketRSI20
	, TRY_CAST(ROUND(RelativeMarketRSI30,  2) AS NUMERIC) AS RelativeMarketRSI30
    , TRY_CAST(ROUND(RelativeMarketRSI60,  2) AS NUMERIC) AS RelativeMarketRSI60
    , TRY_CAST(ROUND(RelativeMarketRSI120, 2) AS NUMERIC) AS RelativeMarketRSI120
	, TRY_CAST(ROUND(RelativeMarketRSI240, 2) AS NUMERIC) AS RelativeMarketRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeSectorRSI5,   2) AS NUMERIC) AS RelativeSectorRSI5
	, TRY_CAST(ROUND(RelativeSectorRSI10,  2) AS NUMERIC) AS RelativeSectorRSI10
	, TRY_CAST(ROUND(RelativeSectorRSI20,  2) AS NUMERIC) AS RelativeSectorRSI20
	, TRY_CAST(ROUND(RelativeSectorRSI30,  2) AS NUMERIC) AS RelativeSectorRSI30
    , TRY_CAST(ROUND(RelativeSectorRSI60,  2) AS NUMERIC) AS RelativeSectorRSI60
    , TRY_CAST(ROUND(RelativeSectorRSI120, 2) AS NUMERIC) AS RelativeSectorRSI120
	, TRY_CAST(ROUND(RelativeSectorRSI240, 2) AS NUMERIC) AS RelativeSectorRSI240
	--------------------------------------------------
	, TRY_CAST(ROUND(RelativeIndustryRSI5,   2) AS NUMERIC) AS RelativeIndustryRSI5
	, TRY_CAST(ROUND(RelativeIndustryRSI10,  2) AS NUMERIC) AS RelativeIndustryRSI10
	, TRY_CAST(ROUND(RelativeIndustryRSI20,  2) AS NUMERIC) AS RelativeIndustryRSI20
	, TRY_CAST(ROUND(RelativeIndustryRSI30,  2) AS NUMERIC) AS RelativeIndustryRSI30
    , TRY_CAST(ROUND(RelativeIndustryRSI60,  2) AS NUMERIC) AS RelativeIndustryRSI60
    , TRY_CAST(ROUND(RelativeIndustryRSI120, 2) AS NUMERIC) AS RelativeIndustryRSI120
	, TRY_CAST(ROUND(RelativeIndustryRSI240, 2) AS NUMERIC) AS RelativeIndustryRSI240
	--------------------------------------------------
	, CASE
		WHEN High5 == HighAll THEN 'All Time High'
		WHEN High5 == High240 THEN 'One Year High'
		WHEN High5 == High120 THEN 'Six Month High'
		WHEN High5 == High60  THEN 'Three Month High'
		WHEN High5 == High20  THEN 'One Month High'
			ELSE '' END AS AlertsBreakout
	, CASE
		WHEN Low5 == LowAll THEN 'All Time Low'
		WHEN Low5 == Low240 THEN 'One Year Low'
		WHEN Low5 == Low120 THEN 'Six Month Low'
		WHEN Low5 == Low60  THEN 'Three Month Low'
		WHEN Low5 == Low20  THEN 'One Month Low'
			ELSE '' END AS AlertsBreakdown
	, CASE
		WHEN RSI20 < 10 THEN 'Panic'
		WHEN RSI20 < 20 THEN 'Oversold'
		WHEN RSI20 > 90 THEN 'Euphoric'
		WHEN RSI20 > 80 THEN 'Overbought'
			ELSE '' END AS AlertsBehavioral

FROM {{ ref('compute_ratios') }}
ORDER BY MarketCap DESC