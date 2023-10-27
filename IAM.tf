
//EKS Cluster Role, this role will be assumed by the cluster
resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      },
    ]
  })
}

//Policies that will be attached to the cluster for it to function.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_policy" "eks_efs_access" {
  name = "EKSWorkerNodeEFSAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["elasticfilesystem:ClientMount", "elasticfilesystem:ClientWrite"]
        Resource = aws_efs_file_system.EFS-Filesystem.arn
      }
    ]
  })
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy that allows Load Balancers to be created by EKS Cluster"

  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Principal = {
                Federated = "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/${module.eks.cluster_id}"
            },
            Action = "sts:AssumeRoleWithWebIdentity",
            Condition = {
                StringEquals = {
                    "oidc.eks.us-west-2.amazonaws.com/id/${module.eks.cluster_id}:aud" = "sts.amazonaws.com",
                    "oidc.eks.us-west-2.amazonaws.com/id/${module.eks.cluster_id}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerPolicyAttachment" {
  role = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}
