resource "helm_release" "nginx" {
  name      = var.cluster_name
  chart     = var.chart_location
  namespace = "default"
  depends_on = [module.eks]

  set {
    name  = "efs.id"
    value = aws_efs_file_system.EFS_Filesystem.id
  }
  set {
    name  = "certificate.arn"
    value = data.aws_acm_certificate.Wildcard-Cert.arn
  }
  set {
    name  = "albsecuritygroups"
    value = aws_security_group.lb_sg.name
  }

}