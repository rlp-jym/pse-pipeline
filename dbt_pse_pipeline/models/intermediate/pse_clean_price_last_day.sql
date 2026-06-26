SELECT *
FROM {{ ref('pse_clean_price_full') }}
WHERE Date = (SELECT MAX(Date) FROM {{ref('pse_clean_price_full')}})