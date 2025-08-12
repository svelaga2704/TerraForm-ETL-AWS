
locals {
  local_raw_dir = "${path.module}/../data/raw"
  raw_csvs      = fileset(local.local_raw_dir, "*.csv")
}

resource "aws_s3_object" "raw_csvs" {
  for_each     = { for f in local.raw_csvs : f => f }
  bucket       = aws_s3_bucket.raw.id
  key          = "input/${each.value}"
  source       = "${local.local_raw_dir}/${each.value}"
  content_type = "text/csv"
  etag         = filemd5("${local.local_raw_dir}/${each.value}")
}

resource "aws_s3_object" "script_join" {
  bucket       = aws_s3_bucket.raw.id
  key          = "scripts/join_to_curated.py"
  source       = "${path.module}/../glue_scripts/join_to_curated.py"
  content_type = "text/x-python"
  etag         = filemd5("${path.module}/../glue_scripts/join_to_curated.py")
}
