SELECT * FROM {{ ref('market_agg') }}
UNION ALL
SELECT * FROM {{ ref('industry_agg') }}