data "aws_lb" "nginx_lb" {
  tags = {
    "kubernetes.io/cluster/k-site" = "owned"
  }
  depends_on = [helm_release.nginx]
}

