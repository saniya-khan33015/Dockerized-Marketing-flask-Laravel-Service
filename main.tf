
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "docker" {}


## Docker resources are commented out to skip Docker builds
# resource "docker_image" "backend" {
#   name         = "backend:latest"
#   build {
#     context    = "${path.module}"
#     dockerfile = "Dockerfile"
#   }
# }
#
# resource "docker_image" "client" {
#   name         = "client:latest"
#   build {
#     context    = "${path.module}/client"
#     dockerfile = "${path.module}/client/Dockerfile"
#   }
# }
#
# resource "docker_container" "backend" {
#   name  = "backend"
#   image = docker_image.backend.name
#   ports {
#     internal = 8000
#     external = 8000
#   }
# }
#
# resource "docker_container" "client" {
#   name  = "client"
#   image = docker_image.client.name
#   ports {
#     internal = 80
#     external = 8080
#   }
# }

# AWS provider configuration
provider "aws" {
  region = var.aws_region
  # Credentials will be picked up from environment variables or GitHub Actions secrets
}

# EC2 instance resource
resource "aws_instance" "example" {
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  key_name               = var.aws_key_name
  subnet_id              = var.aws_subnet_id
  vpc_security_group_ids = [var.aws_security_group_id]
  tags = {
    Name = var.aws_instance_name
  }
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3-pip git
    cd /home/ubuntu
    git clone https://github.com/saniya-khan33015/Dockerized-Marketing-PHP-Laravel-Service.git app
    cd app
    pip3 install -r requirements.txt
    nohup python3 app/main.py &
  EOF
}
# Output EC2 public IP
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

# Output EC2 public DNS
output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.example.public_dns
}

# Variables for AWS EC2 instance
variable "aws_region" {
  description = "AWS region to deploy EC2 instance"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "aws_key_name" {
  description = "Key pair name for EC2 instance"
  type        = string
}

variable "aws_subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "aws_security_group_id" {
  description = "Security group ID for EC2 instance"
  type        = string
}

variable "aws_instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
}
