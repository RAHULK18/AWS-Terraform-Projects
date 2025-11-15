#provider "aws" {
#    region = "us-west-2"
#    profile = "terraform-personal"  
#}

resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags ={
    Name = "Percona-demo-vpc"
  }

}

resource "aws_subnet" "demo_subnet" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet"
  }
}

resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
     Name = "demo-igw"
  }
}
resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
  tags = {
     Name = "demo-rt"
  }
}


resource "aws_route_table_association" "demo_rta" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo_rt.id

}


resource "aws_security_group" "db_sg" {
  
   vpc_id      = aws_vpc.demo_vpc.id

   ingress {

    description = "MySQL internal"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.demo_vpc.cidr_block]
   }

   ingress {

    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
   }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 tags = { Name = "percona-sg" }
}


resource "aws_key_pair" "demo_key" {
   key_name = "terraform-demo-rk"
   public_key = file(var.public_key_path)
}

data "aws_ami" "al2023" {
    most_recent = true
    owners = ["amazon"]
  filter {
    name = "name"
     values = ["al2023-ami-*-x86_64"]
  }
}



module "mysql_master"{
    source = "./modules/ec2_instance"
  instance_name   = "percona-master"
  instance_type   = "t3.medium"
  ami_id          = data.aws_ami.al2023.id
  key_name        = aws_key_pair.demo_key.key_name
  subnet_id       = aws_subnet.demo_subnet.id
  security_groups = [aws_security_group.db_sg.id]

  root_volume_size = 30
  data_volume_size = 10

}


module "mysql_slave"{
    source = "./modules/ec2_instance"
  instance_name   = "percona-slave"
  instance_type   = "t3.medium"
  ami_id          = data.aws_ami.al2023.id
  key_name        = aws_key_pair.demo_key.id
  subnet_id       = aws_subnet.demo_subnet.id
  security_groups = [aws_security_group.db_sg.id]

  root_volume_size = 30
  data_volume_size = 10

}
