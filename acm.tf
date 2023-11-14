data "aws_acm_certificate" "Wildcard-Cert" {
  domain   = "*.codykall.com"
  statuses = ["ISSUED"]
}