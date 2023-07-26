terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.9.0"
    }
  }
}


provider "aws" {
    region = "us-east-1"
    access_key = "AKIAR75SHK5XI5D3BKF2"
    secret_key = "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"
}

resource "aws_vpc" "megento-tf-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "megento-tf-subnet-1" {
    vpc_id = aws_vpc.megento-tf-vpc.id
    cidr_block = "10.0.9.0/24"
    availability_zone = "us-east-1a"
}