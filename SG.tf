

//Controlplane Security Group
resource "aws_security_group" "eks_controlplane_sg" {
    name = "eks_controlplane_sg"
    vpc_id = aws_vpc.VPC_Main.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress"], jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress2"]]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.eks_worker_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}


//EKS Worker Node Security Group
resource "aws_security_group" "eks_worker_sg" {
  name = "eks_worker_sg"
  vpc_id = aws_vpc.VPC_Main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.eks_controlplane_sg.id]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }


}


//Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
    name = "lb_sg"
    vpc_id = aws_vpc.VPC_Main.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress"], jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress2"]]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress"], jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress2"]]
    }
}

resource "aws_security_group" "efs_sg" {
  name = "efs_sg"
  vpc_id = aws_vpc.VPC_Main.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    security_groups = [aws_security_group.eks_worker_sg.id]

  }

}
