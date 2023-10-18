data "aws_secretsmanager_secret_version" "ip_address" {
  secret_id = "arn:aws:secretsmanager:us-west-2:913087840426:secret:IpAddress-8jqo2I"
}