module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.17.2"


  cluster_name = "k-site"
  cluster_version = "1.28"
  subnet_ids = [aws_subnet.Public1.id, aws_subnet.Public2.id]

  cluster_endpoint_public_access = true

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

      labels = {
        server = "nginx"
      }
    }
  }
}