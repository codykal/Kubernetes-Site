
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
        Effect   = "Allow"
        Action   = ["elasticfilesystem:ClientMount", "elasticfilesystem:ClientWrite"]
        Resource = aws_efs_file_system.EFS-Filesystem.arn
      }
    ]
  })
}


//Load Balancer Controller Policy
resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy that allows Load Balancers to be created by EKS Cluster"

  policy = file("${path.module}/iam_policies/iam_policy.json")
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/${local.oidc_id}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.us-west-2.amazonaws.com/id/${local.oidc_id}:aud" = "sts.amazonaws.com",
            "oidc.eks.us-west-2.amazonaws.com/id/${local.oidc_id}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerPolicyAttachment" {
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

//Public ECR Repository Access for Worker Nodes
resource "aws_iam_policy" "ECRPublicRepoAccess" {
  name = "AmazonEKSECRPublicAccessPolicy"
  policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      }
    ]
  })
}

//EFS CSI Driver Policy
resource "aws_iam_role" "AmazonEKS_EFS_CSI_DriverRole" {
  name = "AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/${local.oidc_id}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "oidc.eks.region-code.amazonaws.com/id/${local.oidc_id}:sub" = "system:serviceaccount:kube-system:efs-csi-*",
            "oidc.eks.region-code.amazonaws.com/id/${local.oidc_id}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
    }

  )
}

resource "aws_iam_role_policy_attachment" "EKS_EFS_DriverPolicy_Attachment" {
  role       = aws_iam_role.AmazonEKS_EFS_CSI_DriverRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


//Lambda IAM roles and Policies
resource "aws_iam_policy" "Lambda_S3_EFS_Access_Policy" {
  name = "Lambda_S3_EFS_Access_Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = aws_efs_file_system.EFS_Filesystem.arn
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "Lambda_Role" {
  name = "Lambda_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "EFS_S3_Policy_Attachment" {
  name       = "EFS_S3_Policy_Attachment"
  policy_arn = aws_iam_policy.Lambda_S3_EFS_Access_Policy.arn
  roles = [aws_iam_role.Lambda_Role.id]
}
