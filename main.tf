terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">=2.6.0"
    }
  }

  backend "s3" {
    bucket         = "ecsproject-tfstatebucket"
    key            = "KSite/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-lock-table"

  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}