
output "raw_bucket_name"     { value = aws_s3_bucket.raw.bucket }
output "curated_bucket_name" { value = aws_s3_bucket.curated.bucket }
output "glue_job_name"       { value = aws_glue_job.join_to_curated.name }
