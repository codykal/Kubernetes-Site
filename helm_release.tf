resource "helm_release" "nginx" {
  name = "ksite"
  chart = "helm/ksite"
  namespace = "default"

  set {
    name = "efs.id"
    value = var.efs_id
  }
}