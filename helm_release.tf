resource "helm_release" "nginx" {
  name = "ksite"
  chart = "helm/ksite"
  namespace = "default"

  set {
    name = "efs.id"
    value = aws_efs_file_system.EFS-Filesystem.id
  }
  depends_on = [ module.eks ]
}