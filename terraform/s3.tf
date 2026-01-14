resource "aws_s3_bucket" "default" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.public_access_policy.json
}

data "aws_iam_policy_document" "public_access_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.default.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_acl" "dist_bucket_acl" {
  bucket     = aws_s3_bucket.default.bucket
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.default, aws_s3_bucket_public_access_block.default]
}

resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = aws_s3_bucket.default.bucket
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "default" {
  bucket = aws_s3_bucket.default.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# Upload build files
module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = "${path.module}/../dist"
}

resource "aws_s3_object" "static_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.default.id
  key          = each.key
  content_type = each.value.content_type
  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source      = each.value.source_path
  content     = each.value.content
  source_hash = filemd5(each.value.source_path)
}
