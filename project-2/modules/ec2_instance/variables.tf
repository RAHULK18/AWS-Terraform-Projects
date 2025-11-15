variable "instance_name" {
}

variable "instance_type" {
}
variable "ami_id" {
}
variable "key_name" {
}
variable "subnet_id" {
}
variable "security_groups" {
    type=list(string)
}
variable "root_volume_size" {
}
variable "data_volume_size" {
}
