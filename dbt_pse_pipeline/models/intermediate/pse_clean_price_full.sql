SELECT *,
	ROUND(((Close / "All Time High") - 1) * 100, 2) AS "Relative All Time High",
	ROUND(((Close / "All Time Low")  - 1) * 100, 2) AS "Relative All Time Low",
FROM {{ ref('get_all_time_values') }}