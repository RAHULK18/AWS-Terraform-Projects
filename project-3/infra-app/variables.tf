variable "env" {
  
  type = string
}

variable "bucket_name" {

  type = string
}

variable "instance_count" {

  type = number
}

variable "instance_type" {

  type = string
}

variable "ami_id" {

  type = string
}

variable "aws_security_group" {
   type = string
}
variable "ec2_root_block_size" {

  type = number
}

variable "ec2_az" {
  default = "us-west-2c"
  type = string
}



variable "hash_key" {
  type = string
}
