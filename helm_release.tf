resource "helm_release" "nginx" {
  name      = "k-site"
  chart     = "./helm/ksite"
  namespace = "default"

  set {
    name  = "efs.id"
    value = aws_efs_file_system.EFS-Filesystem.id
  }
  set {
    name  = "certificate.arn"
    value = data.aws_acm_certificate.Wildcard-Cert.arn
  }
  set {
    name  = "albsecuritygroups"
    value = aws_security_group.lb_sg.name
  }

  depends_on = [module.eks]
}