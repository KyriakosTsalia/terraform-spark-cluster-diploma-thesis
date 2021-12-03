# configuration for terraform itself, so it lives inside a terraform block
terraform {
  # add version constraints to prevent automatic upgrades to new major versions that may contain breaking changes
  required_providers {
    aws = {
      version = "~> 3.37"
      source  = "hashicorp/aws"
    }
  }
}