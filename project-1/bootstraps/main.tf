provider "aws" {
  region  = "us-west-2"
  profile = "terraform-project"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "demo-2025-terraform-state"
  acl    = "private"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
