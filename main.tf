
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


## Docker resources removed. Only EC2 instance creation and deployment script remain.

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
    apt-get install -y python3-pip python3-flask
    cat <<EOPY > /home/ubuntu/app.py
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello():
    return 'Hello from your AWS EC2 instance!'
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOPY
    nohup python3 /home/ubuntu/app.py &
  EOF
}
# Output EC2 public IP and URL
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "ec2_public_url" {
  description = "URL to access the deployed app"
  value       = "http://${aws_instance.example.public_ip}"
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
