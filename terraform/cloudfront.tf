resource "aws_cloudfront_distribution" "s3_distribution" {
  comment             = "Andrew React app"
  aliases             = [var.domain.a_record_name]
  default_root_object = "/index.html"
  price_class         = "PriceClass_All"
  enabled             = true

  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
  }

  origin {
    domain_name              = aws_s3_bucket.default.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = local.s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.andrew_web_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code            = "403"
    response_page_path    = "/index.html"
    response_code         = "200"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = "404"
    response_page_path    = "/index.html"
    response_code         = "200"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = "502"
    response_page_path    = "/index.html"
    response_code         = "200"
    error_caching_min_ttl = 10
  }
}

data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_response_headers_policy" "default" {
  name    = "${var.app_name}-security-response-headers"
  comment = "Security response headers (including Content-Security-Policy)"
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name = "${var.app_name}-s3-oac"

  description = "Origin Access Control for ${var.app_name} S3 bucket"

  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}
