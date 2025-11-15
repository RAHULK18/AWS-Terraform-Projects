terraform {
    backend "s3" {
  bucket = "rk-2025-terraform-percona-state"
  key= "global/percona/terraform.tfstate"
  region         = "us-west-2"
  dynamodb_table = "terraform-percona-lock"
  encrypt        = true
  profile        = "terraform-personal"
}
}