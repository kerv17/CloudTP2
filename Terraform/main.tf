variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  default     = "ami-0149b2da6ceec4bb0" // ami_id for us-east-1 linux 
  
}

variable "Data_path" {
  description = "Path to the user data script"
  default     = "Data.sh"
}

variable "m4_instance_count" {
  description = "Number of M4 instances"
  default     = 1
}

variable "t2_instance_count" {
  description = "Number of T2 instances"
  default     = 0
}

variable "instance_tags" {
  description = "Common tags for instances"
  type        = map(string)
  default = {
    "Environment" = "Dev"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret key"
}

variable "token" {
  description = "AWS session token (optional)"
}


provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  token = var.token
}

resource "aws_security_group" "security_gp" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "instances_m4" {
  ami                    = var.ami_id
  instance_type          = "m4.large"
  vpc_security_group_ids = [aws_security_group.security_gp.id]
  availability_zone      = "us-east-1c"
  user_data              = file(var.Data_path)
  count                  = var.m4_instance_count

  tags = merge(var.instance_tags, {
    "Name" = "M4"
  })
}

resource "aws_instance" "instances_t2" {
  ami                    = var.ami_id
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.security_gp.id]
  availability_zone      = "us-east-1d"
  user_data              = file(var.Data_path)
  count                  = var.t2_instance_count

  tags = merge(var.instance_tags, {
    "Name" = "T2"
  })
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "instance_dns" {
  description = "The DNS name of the created instances"
  value       = aws_instance.instances_m4[*].public_dns
}