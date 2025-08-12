
variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "bucket_prefix" {
  type    = string
  default = "etl"
}

variable "glue_job_worker_type" {
  type    = string
  default = "G.1X"
}

variable "glue_job_number_of_workers" {
  type    = number
  default = 2
}
