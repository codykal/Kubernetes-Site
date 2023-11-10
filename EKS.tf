module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"


  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids = var.subnet_ids

  //Control Plane Security Group
  cluster_additional_security_group_ids = [aws_security_group.eks_controlplane_sg.id]

  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = local.ip_addresses

  vpc_id = aws_vpc.VPC_Main.id
  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    iam_role_attach_cni_policy = true
  }


  eks_managed_node_groups = {
    nginx = {
      desired_size = 2
      min_size = 1
      max_size = 2

      remote_access = {
        ec2_ssh_key = data.aws_key_pair.ssh_key.key_name
      }

      //Worker Node Security groups
      vpc_security_group_ids = [aws_security_group.eks_worker_sg.id]

      create_iam_role = true
      iam_role_name = "eks-worker-role"

      iam_role_additional_policies = {
        EFSPolicy = aws_iam_policy.eks_efs_access.arn
        ECRPolicy = aws_iam_policy.ECRPublicRepoAccess.arn
      }

      labels = {
        server = "nginx"
      }
    }
  }
}