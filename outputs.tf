resource "local_file" "outputs" {
  content = jsonencode({
    cluster_name = module.eks.cluster_id,
    cluster_endpoint = module.eks.cluster_endpoint,
    kubeconfig = module.eks.kubeconfig

  })
  filename = "${path.module}/outputs.json"
}

output "kubeconfig" {
  description = "kubeconfig for EKS cluster"
  value = module.eks.kubeconfig
  sensitive = true
}