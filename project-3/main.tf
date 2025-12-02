module "dev-infra" {
    source = "./infra-app"
    env = "dev"
    instance_count = 1
    instance_type = "t2.micro"
    ami_id = "ami-02b297871a94f4b42"
    bucket_name = "rk-project"
    hash_key = "EmpID"
    aws_security_group = "infra"
    ec2_az = "us-west-2c"
    ec2_root_block_size = 10


}

module "stg-infra" {
    source = "./infra-app"
    env = "stg"
    instance_count = 1
    instance_type = "t2.small"
    ami_id = "ami-02b297871a94f4b42"
    bucket_name = "rk-project"
    hash_key = "EmpID"
    aws_security_group = "infra"
    ec2_az = "us-west-2c"
    ec2_root_block_size = 10

}

module "prd-infra" {
    source = "./infra-app"
    env = "prd"
    instance_count = 1
    instance_type = "t2.medium"
    ami_id = "ami-02b297871a94f4b42"
    bucket_name = "rk-project"
    hash_key = "EmpID"
    aws_security_group = "infra"
    ec2_az = "us-west-2c"
    ec2_root_block_size = 10

}

