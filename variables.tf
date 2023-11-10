variable "kube_config" {
  type = string
  default = "~/.kube/config"
}

//EKS Variables
variable "cluster_name" {
  type = string
  default = "k-site"
}

variable "cluster_version" {
  type = string
  default = "1.28"
}

variable "subnet_ids" {
  type = list(string)
  default = [aws_subnet.Public1.id, aws_subnet.Public2.id]
}

