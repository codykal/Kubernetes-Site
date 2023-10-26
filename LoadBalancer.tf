data "aws_lb" "nginx_lb" {
    tags = {
        "kubernetes.io/service-name" = "default/loadbalancer"
    }
    depends_on = [ helm_release.nginx ]
}

