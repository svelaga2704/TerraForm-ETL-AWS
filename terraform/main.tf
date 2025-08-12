
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = "my0746"
  allowed_account_ids = ["074682456135"]
}

data "aws_caller_identity" "current" { }

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  prefix = lower(replace(replace(replace(var.bucket_prefix, " ", "-"), "_", "-"), ".", "-"))

  raw_bucket_name = substr(
    "${local.prefix}-raw-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${random_id.suffix.hex}",
    0, 63
  )
  curated_bucket_name = substr(
    "${local.prefix}-curated-${data.aws_caller_identity.current.account_id}-${var.aws_region}-${random_id.suffix.hex}",
    0, 63
  )
}
