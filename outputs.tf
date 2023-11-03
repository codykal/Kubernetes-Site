//aws eks update-kubeconfig --region us-west-2 --name "k-site"


output "oidc_provider_url" {
  description = "OIDC Provider URL for Cluster"
  value = module.eks.cluster_oidc_issuer_url
}

data "aws_caller_identity" "current_account" {}

output "oidc_id" {
  description = "OIDC Provider ID"
  value = module.eks.oidc_provider.id
  
}
