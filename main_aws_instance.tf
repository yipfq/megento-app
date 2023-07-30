terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.9.0"
    }
  }
}

provider "aws" {}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable env_prefix {}
variable avail_zone {}
variable my_ip {}
variable pk_location {}
variable ec2_type {}


resource "aws_vpc" "megento-tf-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "megento-tf-subnet01" {
  cidr_block = var.subnet_cidr_block
  vpc_id = aws_vpc.megento-tf-vpc.id
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet01"
  }
}

resource "aws_route_table" "megento-tf-rtb" {
  vpc_id = aws_vpc.megento-tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.megento-tf-igw.id
  } 
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "associate_subnet" {
  subnet_id = aws_subnet.megento-tf-subnet01.id
  route_table_id = aws_route_table.megento-tf-rtb.id
  
}

resource "aws_internet_gateway" "megento-tf-igw" {
  vpc_id = aws_vpc.megento-tf-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.megento-tf-vpc.id
  tags = {
    Name = "${var.env_prefix}-sg"
  }

  #Ingress rule 1
  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Ingress rule 2
  ingress  {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

resource "aws_key_pair" "default_kp" {
  key_name = "default_kp"
  public_key = file(var.pk_location)
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }  
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "aws_ec2_public_IP" {
  value = aws_instance.megento-tf-server.public_ip
  
}

resource "aws_instance" "megento-tf-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.ec2_type
  key_name = aws_key_pair.default_kp.key_name

  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  subnet_id = aws_subnet.megento-tf-subnet01.id
  availability_zone = var.avail_zone
  associate_public_ip_address = true
}
