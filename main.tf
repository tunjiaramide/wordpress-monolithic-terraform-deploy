# Create a Wordpress using default VPC without keypair

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# Create a security group
resource "aws_security_group" "wordpress_sg" {
  name        = "allow_http"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wordpress_sg"
  }
}

# Create a web instance with user data to install wordpress
resource "aws_instance" "web_server" {
  ami                    = "ami-007855ac798b5175e" #ubuntu 22.04
  instance_type          = "t2.micro"
  user_data              = file("userdata.tpl")
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]
  tags = {
    Name = "Wordpress_Starter"
  }
}

output "public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public address of the IP"
}
