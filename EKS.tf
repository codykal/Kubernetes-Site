module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.17.2"


  cluster_name = "k-site"
  cluster_version = "1.28"
  subnet_ids = [aws_subnet.Public1.id, aws_subnet.Public2.id]

  vpc_id = aws_vpc.VPC_Main.id
  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = ["t3.small"]
    iam_role_attach_cni_policy = true
  }
}