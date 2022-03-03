terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = "EDIT_HERE"
  secret_key = "EDIT_HERE"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "EDIT_HERE"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "slurm-cluster-sg" {
  name = "slurm-cluster-sg"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 111
    to_port         = 111
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 111
    to_port         = 111
    protocol        = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 6817
    to_port         = 6818
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "master-node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "master"
    Role = "master"
  }
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.slurm-cluster-sg.id]
}

resource "aws_instance" "worker-node" {
  ami = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"
  count         = 5

  tags = {
    Name = "worker-${count.index + 1}"
    Role = "worker"
  }
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.slurm-cluster-sg.id]
}
