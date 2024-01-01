data "aws_key_pair" "ssh_key" {
  key_name = var.ssh_key
}