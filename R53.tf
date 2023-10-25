data "aws_route53_zone" "Topdomain-zone" {
  name = "codykall.com"
}

resource "aws_route53_record" "docs_subdomain" {
  zone_id = data.aws_route53_zone.Topdomain-zone.zone_id
  name    = "docs.codykall.com"
  type    = "A"

  alias {
    name                   = aws_lb.nginx_lb.dns_name
    zone_id                = aws_lb.nginx_lb.zone_id
    evaluate_target_health = true
  }
}