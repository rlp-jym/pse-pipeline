SELECT *
FROM read_parquet(
	's3://pse-price/*.parquet', 
	union_by_name=True
)