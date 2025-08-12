
resource "aws_glue_job" "join_to_curated" {
  name              = "join-to-curated"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  worker_type       = var.glue_job_worker_type
  number_of_workers = var.glue_job_number_of_workers
  max_retries       = 0

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.raw.bucket}/scripts/join_to_curated.py"
  }

  default_arguments = {
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--enable-metrics"                   = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--RAW_BUCKET"                       = aws_s3_bucket.raw.bucket
    "--CURATED_BUCKET"                   = aws_s3_bucket.curated.bucket
  }
}
