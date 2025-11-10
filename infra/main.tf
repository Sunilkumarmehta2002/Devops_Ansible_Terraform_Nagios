terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "provertos_sg" {
  name        = "provertos-sg"
  description = "Allow SSH, HTTP, API and Nagios"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5666
    to_port     = 5666
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                           = data.aws_ami.amazon_linux_2.id
  instance_type                 = var.instance_type
  key_name                      = var.ssh_key_name != "" ? var.ssh_key_name : null
  associate_public_ip_address   = true
  vpc_security_group_ids        = [aws_security_group.provertos_sg.id]
  tags = { Name = "provertos-web" }
}

resource "aws_instance" "api" {
  ami                           = data.aws_ami.amazon_linux_2.id
  instance_type                 = var.instance_type
  key_name                      = var.ssh_key_name != "" ? var.ssh_key_name : null
  associate_public_ip_address   = true
  vpc_security_group_ids        = [aws_security_group.provertos_sg.id]
  tags = { Name = "provertos-api" }
}

resource "aws_instance" "nagios" {
  ami                           = data.aws_ami.amazon_linux_2.id
  instance_type                 = var.instance_type
  key_name                      = var.ssh_key_name != "" ? var.ssh_key_name : null
  associate_public_ip_address   = true
  vpc_security_group_ids        = [aws_security_group.provertos_sg.id]
  tags = { Name = "provertos-nagios" }
}
