data "aws_lb" "nginx-lb" {
    tags = {
        "kubernetes.io/service-name" = "default/loadbalancer"
    }
    depends_on = [ helm_release.nginx ]
}

