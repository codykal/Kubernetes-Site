resource "helm_release" "nginx" {
  name = "ksite"
  chart = "./helm/ksite"
  namespace = "default"

  set {
    name = "efs.id"
    value = aws_efs_file_system.EFS-Filesystem.id
  }
  set {
    name = "account_id.id"
    value = data.aws_caller_identity.current_account.account_id
  }

  depends_on = [ module.eks ]
}