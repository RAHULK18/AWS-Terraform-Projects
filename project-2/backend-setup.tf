provider "aws" {
  region = "us-west-2"
  profile = "terraform-personal"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "rk-2025-terraform-percona-state"
   tags = {
    Name = "Terraform state bucket"
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

resource "aws_dynamodb_table" "tf_lock" {
  name = "terraform-percona-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

 attribute {
   name = "LockID"
   type = "S"
 }

 tags = {
    Name = "Terraform Lock Table"
 }
}

