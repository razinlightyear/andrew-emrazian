resource "aws_route53_record" "cloudfront_web_record" {
  name    = var.domain.a_record_name
  type    = "A"
  zone_id = data.aws_route53_zone.default.zone_id

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "andrew_web_cert" {
  provider          = aws.acm
  domain_name       = var.domain.a_record_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.andrew_web_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.default.zone_id
}

resource "aws_acm_certificate_validation" "andrew_web_cert_validation" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.andrew_web_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

data "aws_route53_zone" "default" {
  name = var.domain.zone_name
}
