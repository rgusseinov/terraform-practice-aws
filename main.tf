provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.5"
  backend "s3" {}
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

resource "aws_network_interface" "my_network_interface" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "my_instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ssh.id]
  
  key_name = "my-new-key"

  count = 2

  credit_specification {
    cpu_credits = "unlimited"
  }

  user_data = <<-EOF
                  #!/bin/bash
                  sudo dnf install -y httpd php
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  echo "<?php echo 'Hello world!'; ?>" | sudo tee /var/www/html/index.php > /dev/null

                  sudo systemctl restart httpd
                  EOF

  tags = {
    Name = count.index == 0 ? "dev" : "staging"
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

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSH"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my_vpc.id
  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.route_table.id
}