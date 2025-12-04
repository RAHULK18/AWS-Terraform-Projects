locals {
   region = "us-west-2"
   name = "eks-cluster-rk"
   vpc_cidr = "10.0.0.0/16"
   azs = ["us-west-2c","us-west-2a"]
   private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
   public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
   intra_subnets = ["10.0.5.0/24","10.0.6.0/24"]
   env = "Dev"
}