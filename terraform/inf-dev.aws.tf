provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_vpc" "terraform_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform Custom VPC"
  }
}

resource "aws_subnet" "terraform_database_private_subnet" {
  vpc_id            = aws_vpc.terraform_custom_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Terraform Database Private Subnet"
  }
}

resource "aws_subnet" "terraform_app_private_subnet" {
  vpc_id            = aws_vpc.terraform_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Terraform App Private Subnet"
  }
}

resource "aws_subnet" "terraform_nginx_public_subnet" {
  vpc_id            = aws_vpc.terraform_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Terraform Nginx Public Subnet"
  }
}

resource "aws_internet_gateway" "terraform_ig" {
  vpc_id = aws_vpc.terraform_custom_vpc.id

  tags = {
    Name = "Terraform Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terraform_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.terraform_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = aws_subnet.terraform_nginx_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "terraform_nginx_sg" {
  name   = "Nginx 80 SSH"
  vpc_id = aws_vpc.terraform_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "terraform_app_sg" {
  name   = "app 8080"
  vpc_id = aws_vpc.terraform_custom_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "terraform_mongo_sg" {
  name   = "mongo 27017"
  vpc_id = aws_vpc.terraform_custom_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_instance" {
  ami           = "ami-05481a4fad6dd57b1"
  instance_type = "t2.nano"
  key_name      = "us-west-2-key"

  subnet_id                   = aws_subnet.terraform_nginx_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.terraform_nginx_sg.id]
  associate_public_ip_address = true

  tags = {
  }
}

resource "aws_instance" "app_instance" {
  ami           = "ami-01a811b8636a7b54e"
  instance_type = "t2.nano"
  key_name      = "us-west-2-key"

  private_ip = "10.0.2.10"

  subnet_id                   = aws_subnet.terraform_app_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.terraform_app_sg.id]
  associate_public_ip_address = false

  tags = {
  }
}

resource "aws_instance" "mongo_instance" {
  ami           = "ami-03477437025a39b0c"
  instance_type = "t2.nano"
  key_name      = "us-west-2-key"

  private_ip = "10.0.3.10"

  subnet_id                   = aws_subnet.terraform_database_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.terraform_mongo_sg.id]
  associate_public_ip_address = false

  tags = {
  }
}