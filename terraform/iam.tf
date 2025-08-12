
data "aws_iam_policy_document" "glue_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_role" {
  name               = "etl-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume.json
}

data "aws_iam_policy_document" "glue_access" {
  statement {
    sid     = "S3Access"
    actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:ListBucket"]
    resources = [
      aws_s3_bucket.raw.arn,
      "${aws_s3_bucket.raw.arn}/*",
      aws_s3_bucket.curated.arn,
      "${aws_s3_bucket.curated.arn}/*"
    ]
  }
  statement {
    sid     = "LogsAccess"
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:DescribeLogStreams"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue_inline_access" {
  name   = "etl-glue-access"
  role   = aws_iam_role.glue_role.id
  policy = data.aws_iam_policy_document.glue_access.json
}

resource "aws_iam_role_policy_attachment" "glue_managed" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
