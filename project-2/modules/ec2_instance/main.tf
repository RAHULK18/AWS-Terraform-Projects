resource "aws_instance" "ec2" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  key_name = var.key_name
  vpc_security_group_ids = var.security_groups


tags = {
    Name = var.instance_name
}

root_block_device {
    #device_name = "/dev/xvda"
    volume_size = var.root_volume_size
    volume_type = "gp3"
}

ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = var.data_volume_size
    volume_type = "gp3"
}

}