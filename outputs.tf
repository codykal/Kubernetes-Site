//aws eks update-kubeconfig --name "k-site"


output "oidc_provider_url" {
  description = "OIDC Provider URL for Cluster"
  value = module.eks.cluster_oidc_issuer_url
}

data "aws_caller_identity" "current_account" {}
