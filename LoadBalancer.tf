data "aws_lb" "nginx_lb" {
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
  depends_on = [helm_release.nginx]
}

