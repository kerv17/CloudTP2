variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  default     = "ami-0149b2da6ceec4bb0"// Replace with Ubuntu AMI ID for us-east-1
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

data "aws_vpc" "default" {
  default = true
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

resource "aws_key_pair" "my_keyy" {
  key_name   = "my-key-nassme"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDat9II8dtn5bNMsFrpQQNlSybtVCnKP3mdx+2N8cqZxhQGxEuvZfbq15qPuOFshmyhsPDmC9UxdK08cuLfscOwC73DUJ24BbQNlJBAH4mnh7TOida3tbWNByF6F9OvKW6FMZdVnfVtcBZAmkAr18T82/EiPQGp4fVpuquNwrZtaW2XVETqQbh97Y/YMH7rVLfLhn9hh+jB9o2XJCBMcN+3F5QNmFfPm9Ca7KNIr13oEcMHZGVoI4GRrvz/alZgsiMO+ot1ubuAJk0U/jQMoWIqGMR6pxqvHRURvAcQxvOToTJOx58ln2hG5kGxgMDqd73aASf9M9HLkZJHqFkM0SFt rsa-key-20231113"
}

resource "aws_instance" "instances_m4" {
  ami                    = var.ami_id
  instance_type          = "m4.large"
  vpc_security_group_ids = [aws_security_group.security_gp.id]
  availability_zone      = "us-east-1c"
  user_data              = file(var.Data_path)
  count                  = var.m4_instance_count
  key_name               = aws_key_pair.my_keyy.key_name

  tags = merge(var.instance_tags, {
    "Name" = "M4"
  })
}

output "instance_dns" {
  description = "The DNS name of the created instances"
  value       = aws_instance.instances_m4[*].public_dns
}