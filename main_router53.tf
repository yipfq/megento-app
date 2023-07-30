terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.9.0"
    }
  }
}

provider "aws" {}

resource "aws_route53_zone" "megento-domain" {
  name = "learningawswithalex.com"
}

resource "aws_route53_record" "magento_hosted_zone_record" {
    zone_id = aws_route53_zone.megento-domain.id
    name = "www.learningawswithalex.com"
    type = "A"
    ttl = 300
    records = [aws_instance.megento-tf-server.public_ip]
  
}