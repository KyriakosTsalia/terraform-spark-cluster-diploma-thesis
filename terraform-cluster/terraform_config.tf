# configuration for terraform itself, so it lives inside a terraform block
terraform {
  # use the s3 backend to store remote state
  backend "s3" {
    # the name of s3 bucket to use
    bucket = "terraform-spark-cluster"
    # the path within the s3 bucket where the terraform state file will be written
    key = "terraform/terraform.tfstate"
  }
  # add version constraints to prevent automatic upgrades to new major versions that may contain breaking changes
  required_providers {
    aws = {
      version = "~> 3.37"
      source  = "hashicorp/aws"
    }
    cloudinit = {
      version = "~> 2.2"
      source  = "hashicorp/cloudinit"
    }
    null = {
      version = "~> 3.1"
      source  = "hashicorp/null"
    }
    template = {
      version = "~> 2.2"
      source  = "hashicorp/template"
    }
  }
}