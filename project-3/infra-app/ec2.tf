#key pair

resource "aws_key_pair" "rk-key" {
    key_name = "${var.env}-terraform-rk-key-ec2"
    public_key = file("/Users/rahulkarmakar/Desktop/terraform-demo.pub")
tags = {
  Environment = var.env
}
}

#vpc

resource "aws_vpc" "rk-vpc" {
     cidr_block = "10.0.0.0/16"
    tags = {
      Name = "${var.env}-rk-vpc"
    }
}

resource "aws_subnet" "rk-subnet" {
     vpc_id = aws_vpc.rk-vpc.id
     cidr_block = "10.0.1.0/24"
     availability_zone = var.ec2_az
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.env}-rk-subnet"
    }
}

resource "aws_internet_gateway" "rk-igw" {
  vpc_id = aws_vpc.rk-vpc.id
  tags = {
    Name = "${var.env}-rk-igw"
  }
}

resource "aws_route_table" "rt-rk" {
  vpc_id = aws_vpc.rk-vpc.id


  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.rk-igw.id

    }
}
resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.rk-subnet.id
  route_table_id = aws_route_table.rt-rk.id
}



resource "aws_security_group" "rk-sg" {
  name = "${var.env}-automate-sg"
  description = "tf generated sg"
  vpc_id = aws_vpc.rk-vpc.id

  tags = {
 Name =  "${var.env}-automate-sg"
  }
  ingress {
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
     description = "SSH"

  }
  ingress {
     from_port = 80
     to_port = 80
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
     description = "HTTP"

  }

  egress  {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
     description = "All"
  }
}


resource "aws_instance" "rk-ec2" {
  count = var.instance_count
  #depends_on = [ aws_security_group.rk-sg ]
  ami = var.ami_id #interpolation
  instance_type = var.instance_type
  availability_zone = var.ec2_az
  key_name = aws_key_pair.rk-key.key_name
  subnet_id = aws_subnet.rk-subnet.id
  vpc_security_group_ids = [aws_security_group.rk-sg.id]  
  #user_data = file("/Users/rahulkarmakar/Desktop/Terraform/project-5/infra-app/user_data.sh")
  root_block_device {
    volume_size = var.env == "prd" ? 20 : var.ec2_root_block_size #conditional
    volume_type = "gp3"
  }

 tags = {
    Name = "${var.env}-ec2"
    
 }  
}

