terraform {
  required_version = ">= 1.5"
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  
  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet.id

  vpc_security_group_ids = [aws_security_group.ssh.id]

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "ssh" {
  name = "Allow SSH"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSH"
  }
}
