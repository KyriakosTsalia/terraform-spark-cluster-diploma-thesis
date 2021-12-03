module "vpc" {
  source = "./modules/vpc-module"

  REGION               = var.AWS_REGION
  IP_RANGE             = var.IP_RANGE_FOR_VPC_MODULE
  INSTANCE_TENANCY     = "default"
  ENABLE_DNS_SUPPORT   = "true"
  ENABLE_DNS_HOSTNAMES = "true"
  ENABLE_CLASSICLINK   = "false"
  PUBLIC_SUBNETS       = var.PUBLIC_SUBNETS_FOR_VPC_MODULE
  PRIVATE_SUBNETS      = var.PRIVATE_SUBNETS_FOR_VPC_MODULE
}

