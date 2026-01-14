provider "aws" {
  region = var.region
  assume_role {
    role_arn = local.cross_account_role_arn
  }
}

provider "aws" {
  alias  = "acm"
  region = var.aws_account.acm_region
  assume_role {
    role_arn = local.cross_account_role_arn
  }
}

locals {
  cross_account_role_arn = "arn:aws:iam::${var.aws_account.id}:role/${var.aws_account.iam_role_name}"
  s3_origin_id           = var.app_name
}
