resource "aws_vpc" "VPC_Main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "IGW_Main" {
  vpc_id = aws_vpc.VPC_Main.id
}

resource "aws_route_table" "RT_Main" {
  vpc_id = aws_vpc.VPC_Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_Main.id
  }
}

resource "aws_route_table_association" "subnet1_route" {
  subnet_id      = aws_subnet.Public1.id
  route_table_id = aws_route_table.RT_Main.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.Public2.id
  route_table_id = aws_route_table.RT_Main.id
}