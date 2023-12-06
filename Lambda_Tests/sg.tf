resource "aws_security_group" "lambda_sg" {
  name = "lambda_sg"
  description = "Security group for Lambda Function"
  vpc_id = aws_vpc.VPC_Main.id

  ingress {
    from_port = 443
    to_port = 443    
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.VPC_Main.id

  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups  = [aws_security_group.lambda_sg.id]
  }
}