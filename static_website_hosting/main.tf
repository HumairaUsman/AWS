provider "aws" {
    region = var.region
}

resource "aws_s3_bucket" "website_bucket" {
    bucket = var.domain_name
    tags = var.tags

}

resource "aws_s3_bucket_public_access_block" "website_bucket"{
    bucket = aws_s3_bucket.website_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.website_bucket.id
    index_document {
        suffix = var.index_document
    }
}

resource "aws_acm_certificate" "cert" {
    domain_name       = var.domain_name
    validation_method = "DNS"
    tags              = var.tags

    lifecycle {
        create_before_destroy = true
    }
}


data "aws_route53_zone" "url_name"{
    name = var.domain_name
    private_zone = false
}

# This creates the DNS record for ACM validation
resource "aws_route53_record" "cert_validation" {
    for_each = {
        for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
    zone_id         = data.aws_route53_zone.url_name.zone_id
    }

# This tells Terraform to wait for the certificate to be "Issued"
resource "aws_acm_certificate_validation" "cert" {
    certificate_arn = aws_acm_certificate.cert.arn
    validation_record_fqdns = [for record in aws_aws_route53_record.cert_validation : record_fqdn]
  
}

#create Cloudfront for CDN(sits in front of s3 to make website accessible faster)
resource "aws_cloudfront_distribution" "s3_distribution" {
    origin{
        domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
        origin_id = "S3-{domain_name}"
    }
    enabled = true
    is_ipv6_enabled = true
    default_root_object = var.index_document
    aliases = [var.domain_name]

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "S3-${var.domain_name}"

        forwarded_values {
        query_string = false
        cookies { forward = "none" }
        }

        viewer_protocol_policy = "redirect-to-https"
    }

    viewer_certificate {
        acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    restrictions {
        geo_restriction { restriction_type = "none" }
    }

    tags = var.tags
}

#Route53 alias creation
resource "aws_route53_record" "root_a" {
    zone_id = data.aws_route53_zone.cert.zone_id
    name    = var.domain_name
    type    = "A"
    alias {
      name = aws_cloudfront_distribution.s3_distribution.domain_name
      zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
      evaluate_target_health = false
    }
    
}
