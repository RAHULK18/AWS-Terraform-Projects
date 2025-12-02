terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

/*backend "s3" {

  bucket = "${var.env}-${var.bucket_name}"
  key = "terraform.tfstate"
  region = "us-west-2"
  dynamodb_table = "${var.env}-rk-state-management"
  profile = "terraform-personal"
  #use_lockfile = true
}
}*/



