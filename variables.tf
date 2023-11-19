variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

//EKS Variables
variable "cluster_name" {
  type    = string
  default = "k-site"
}

variable "cluster_version" {
  type    = string
  default = "1.28"
}

variable "desired_size" {
  type = number
  default = 2
}

variable "min_size" {
  type = number
  default = 1
}

variable "max_size" {
  type = number
  default = 2
}

//Chart Location
variable "chart_location" {
  type = string
  default = "./helm/k-site"
}

