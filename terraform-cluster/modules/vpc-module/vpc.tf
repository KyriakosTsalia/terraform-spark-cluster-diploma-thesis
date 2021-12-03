# dynamically find the available zones for the specified aws region
data "aws_availability_zones" "available" {
  state = "available"
}

# declare local value to simplify the configuration file
locals {
  available_zones = data.aws_availability_zones.available.names
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.IP_RANGE             # VPC address range
  instance_tenancy     = var.INSTANCE_TENANCY     # allow multiple instances on a physical machine
  enable_dns_support   = var.ENABLE_DNS_SUPPORT   # enable DNS support in the VPC
  enable_dns_hostnames = var.ENABLE_DNS_HOSTNAMES # enable DNS hostnames in the VPC
  enable_classiclink   = var.ENABLE_CLASSICLINK   # disable link between the VPC and EC2 Classic

  tags = {
    Name = "main"
  }
}

# Subnets
# Public
resource "aws_subnet" "main-public" {
  count                   = length(local.available_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PUBLIC_SUBNETS[count.index]    # subnet address range
  map_public_ip_on_launch = "true"                             # give every instance a public IP on launch
  availability_zone       = local.available_zones[count.index] # datacenter choice 

  tags = {
    Name = "main-public-${count.index + 1}"
  }
}

# Private
resource "aws_subnet" "main-private" {
  count                   = length(local.available_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PRIVATE_SUBNETS[count.index]
  map_public_ip_on_launch = "false" # instances will not be given a public IP on launch
  availability_zone       = local.available_zones[count.index]

  tags = {
    Name = "main-private-${count.index + 1}"
  }
}

# Internet Gateway - for the public subnets
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# Route Tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" # all external traffic will be routed over the internet gw
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "main-public"
  }
}

# Route Associations - Public
# associate the route table with every public subnet
resource "aws_route_table_association" "main-public" {
  count          = length(local.available_zones)
  subnet_id      = aws_subnet.main-public[count.index].id
  route_table_id = aws_route_table.main-public.id
}