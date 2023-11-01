resource "helm_release" "nginx" {
  name = "ksite"
  chart = "./helm/ksite"
  namespace = "default"

  set {
    name = "efs.id"
    value = aws_efs_file_system.EFS-Filesystem.id
  }
  set {
    name = "certificate.arn"
    value = data.aws_acm_certificate.Wildcard-Cert.arn
  }
  set {
    name = "alb-security-groups"
    value = aws_security_group.lb_sg.name
  }

  depends_on = [ module.eks ]
}