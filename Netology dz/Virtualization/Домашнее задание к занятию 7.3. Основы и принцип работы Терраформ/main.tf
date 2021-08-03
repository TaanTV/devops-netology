provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_s3_bucket" "ubuntu" {
  bucket = "my-tf-test-bucket"
  acl    = "private"
}

locals {
  netology_instance_type_map = {
    stage = "t2.micro"
    prod  = "t3.micro"
  }

  netology_instance_count_map = {
    stage = 1
    prod  = 2
  }
}

resource "aws_instance" "netology" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.netology_instance_type_map[terraform.workspace]
}

resource "aws_instance" "for_each" {
  for_each = toset( ["Netology1", "netology2", "netology3", "netology4"] )
  lifecycle {
 create_before_destroy = true
 prevent_destroy = true
 ignore_changes = [tags]
 }
  ami           = data.aws_ami.ubuntu.id
  instance_type = "local.netology_instance_type_map"
}
