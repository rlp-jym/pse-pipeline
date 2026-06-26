SELECT *,
	regexp_replace(
		regexp_replace(
			regexp_replace("company_details.subsector",
				',', '', 'g'),
				'and', '&', 'g'),
				'Infrastructure', 'Infra.', 'g') AS clean_industry
FROM read_parquet(
	's3://pse-meta/*.parquet',
	union_by_name=True
)