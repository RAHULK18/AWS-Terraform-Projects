variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_key_path" {
  default = "/Users/rahulkarmakar/Desktop/terraform-demo.pub"
}

variable "my_ip" {
  description = "Own public IP with /32"
  default     = "0.0.0.0/0" # replace later
}