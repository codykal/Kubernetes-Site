data "aws_acm_certificate" "Wildcard-Cert" {
  domain   = var.domain_wildcard
  statuses = ["ISSUED"]
}

#Make Sure that domain name is already issued