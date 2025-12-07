#########################################
# S3 BUCKET (private)
#########################################
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

# Block ALL public access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################
# Origin Access Control (OAC)
#########################################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#########################################
# CloudFront Distribution
#########################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

#########################################
# Bucket Policy: Allow ONLY CloudFront
#########################################
data "aws_iam_policy_document" "cf_to_s3" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.website.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.cf_to_s3.json
}

#########################################
# Upload Website Files to S3
#########################################

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.website.id
  key    = "error.html"
  source = "${path.module}/error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "logo" {
  bucket = aws_s3_bucket.website.id
  key    = "rk-static.png"
  source = "${path.module}/rk-static.png"
  content_type = "image/png"
}
