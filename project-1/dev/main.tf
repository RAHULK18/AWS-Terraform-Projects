provider "aws" {
  region = var.region
  profile = var.profile
}

terraform {
  backend "s3" {

    bucket = "demo-2025-terraform-state"
    key = "dev/networking/terraform.tfstate"
    region = "us-west-2"
    #dynamodb_table = "terraform-state-lock"
    use_lockfile = true
    encrypt = true
  }
required_version = ">= 1.13"
 
}



module "vpc" {
   source = "../modules/vpc" 
   vpc_name = "dev_vpc"
   cidr_block = "10.0.0.0/16"
   azs = ["us-west-2a", "us-west-2c"]
   public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24" ]
   private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24" ]
   enable_nat_gateway = true
   single_nat_gateway = true
   tags = {
    Environment = "dev"
    Project = "Demo"
   }

}

output "vpc_id" {
  value = module.vpc.vpc_id
}