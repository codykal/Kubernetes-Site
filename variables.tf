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
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}


//Chart Location
variable "chart_location" {
  type    = string
  default = "./helm/k-site"
}

//ACM Variable
variable "domain_wildcard" {
  type    = string
  default = "*.codykall.com"
}

//SSH Key Variable
variable "ssh_key" {
  type    = string
  default = "Project3-SSHKey"
}

//Lambda Variables
variable "lambda_function_name" {
  type    = string
  default = "push_to_efs"
}

variable "local_mount_path" {
  type    = string
  default = "/mnt/efs"
}

variable "source_file_name" {
  type    = string
  default = "./push_to_efs.py"
}

variable "output_path" {
  type    = string
  default = "./lambda_function.zip"
}