locals {
  ip_addresses = [
    jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress"], 
    jsondecode(data.aws_secretsmanager_secret_version.ip_address.secret_string)["ipaddress2"]
  ]
}


//Security Group Rules
locals {
  controlplane_rules = {
    "local_ingress" = {
        type = "ingress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = local.ip_addresses
        security_group_id = aws_security_group.eks_controlplane_sg.id
    },
    "worker_ingress" = {
        type = "ingress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_worker_sg.id
        security_group_id = aws_security_group.eks_controlplane_sg.id
    },
    "local_egress" = {
        type = "egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = local.ip_addresses
        security_group_id = aws_security_group.eks_controlplane_sg.id
    },
    "worker_egress" = {
        type = "egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_worker_sg.id
        security_group_id = aws_security_group.eks_controlplane_sg.id
    }
  }

  worker_rules = {
    "self_ingress" = {
        type = "ingress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = true
        security_group_id = aws_security_group.eks_worker_sg.id
    },
    "controlplane_ingress" = {
        type = "ingress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_controlplane_sg.id
        security_group_id = aws_security_group.eks_worker_sg.id
    },
    "lb_ingress" = {
        type = "ingress"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        source_security_group_id = aws_security_group.lb_sg.id
        security_group_id = aws_security_group.eks_worker_sg.id
    },
    "controlplane_egress" = {
        type = "egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_controlplane_sg.id
        security_group_id = aws_security_group.eks_worker_sg.id
    }
    "lb_egress" = {
        type = "egress"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        source_security_group_id = aws_security_group.lb_sg.id
        security_group_id = aws_security_group.eks_worker_sg.id
    }
  }

  efs_rules = {
    "worker_ingress" = {
        type = "ingress"
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        source_security_group_id = aws_security_group.eks_worker_sg.id
        security_group_id = aws_security_group.efs_sg.id
    },
    "worker_egress" = {
        type = "egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_worker_sg.id
        security_group_id = aws_security_group.efs_sg.id
    }
  }

  load_balancer_rules = {
    "local_ingress_443" = {
        type = "ingress"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = local.ip_addresses
        security_group_id = aws_security_group.lb_sg.id
    },
    "local_ingress_80" = {
        type = "ingress"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = local.ip_addresses
        security_group_id = aws_security_group.lb_sg.id
    },
    "local_egress" = {
        type = "egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = local.ip_addresses
        security_group_id = aws_security_group.lb_sg.id
    }
    "worker_ingress" = {
        type = "ingress"
        from_port = 0
        to_port = 0
        protocol = "-1"
        source_security_group_id = aws_security_group.eks_worker_sg.id
        security_group_id = aws_security_group.lb_sg.id
    }

  }
  
}

locals {
  oidc_id = module.eks.oidc_provider.id
}