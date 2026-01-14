variable "region" {
  description = "AWS region to default to. Most of these components are global (cloudfront, S3)"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "app name to be used in naming resources"
  type        = string
  default     = "andrew-emrazian-web"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "andrew-emrazian-web"
}

variable "domain" {
  description = "Info needed to create a domain name in Route 53"
  type = object({
    zone_name     = string
    a_record_name = string
  })
  default = {
    zone_name     = "andrew.emrazian.com"
    a_record_name = "andrew.emrazian.com"
  }
}

variable "aws_account" {
  description = "AWS account configuration"
  type = object({
    id            = string
    iam_role_name = string
    region        = string
    acm_region    = string
  })
}