

//Controlplane Security Group
resource "aws_security_group" "eks_controlplane_sg" {
  name   = "eks_controlplane_sg"
  vpc_id = aws_vpc.VPC_Main.id
}

resource "aws_security_group_rule" "controlplane_rules" {
  for_each = local.controlplane_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  security_group_id        = each.value.security_group_id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}


//EKS Worker Node Security Group
resource "aws_security_group" "eks_worker_sg" {
  name   = "eks_worker_sg"
  vpc_id = aws_vpc.VPC_Main.id
}

resource "aws_security_group_rule" "worker_rules" {
  for_each = local.worker_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  security_group_id        = lookup(each.value, "security_group_id", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  self                     = lookup(each.value, "self", null)
}


//Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name   = "lb_sg"
  vpc_id = aws_vpc.VPC_Main.id
}

resource "aws_security_group_rule" "load_balancer_rules" {
  for_each = local.load_balancer_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  security_group_id        = each.value.security_group_id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

//EFS Security Group
resource "aws_security_group" "efs_sg" {
  name   = "efs_sg"
  vpc_id = aws_vpc.VPC_Main.id
}

resource "aws_security_group_rule" "efs_rules" {
  for_each = local.efs_rules

  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  security_group_id        = each.value.security_group_id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

// Lambda Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda Function"
  vpc_id      = aws_vpc.VPC_Main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}