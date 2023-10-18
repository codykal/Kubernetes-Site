
//EKS Cluster Role, this role will be assumed by the cluster
resource "aws_iam_role" "eksClusterRole" {
    name = "eksClusterRole"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
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
    role = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = aws_iam_role.eksClusterRole.name
}