SELECT *
FROM {{ ref('extend_price') }}
WHERE Date = (SELECT MAX(Date) FROM {{ref('extend_price')}})