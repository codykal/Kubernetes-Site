resource "aws_subnet" "Public1" {
  vpc_id                  = aws_vpc.VPC_Main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "Public2" {
  vpc_id                  = aws_vpc.VPC_Main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "Private1" {
  vpc_id     = aws_vpc.VPC_Main.id
  cidr_block = "10.0.3.0/24"
}

resource "aws_subnet" "Private2" {
  vpc_id     = aws_vpc.VPC_Main.id
  cidr_block = "10.0.4.0/24"
}