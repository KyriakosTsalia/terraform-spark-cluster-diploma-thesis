variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "SPARK_MASTER_INSTANCE_TYPE" {
  default = "c5.large" // 2 vCPUs, 4GB RAM
}

variable "SPARK_WORKER_INSTANCE_TYPE" {
  default = "c5.xlarge" // 4 vCPUs, 8GB RAM
}
variable "SPARK_GATEWAY_INSTANCE_TYPE" {
  default = "c5.xlarge"
}
variable "PROM_GRAF_SERVER_INSTANCE_TYPE" {
  default = "c5.large"
}
variable "NUMBER_OF_SPARK_WORKERS" {
  default = 6
}

# zero-pad the name - up to 2 digits - e.g. spark-worker-00, spark-worker-42
variable "SPARK_WORKER_NAME_FORMAT" {
  default = "spark-worker-%02d"
}

variable "IP_RANGE_FOR_VPC_MODULE" {
  default = "10.0.0.0/16"
}

variable "PUBLIC_SUBNETS_FOR_VPC_MODULE" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "PRIVATE_SUBNETS_FOR_VPC_MODULE" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}


variable "AMIS" {
  type = map(string)
  default = {
    # focal 20.04LTS amd64 hvm:ebs-ssd AMIS for the corresponding EU regions
    # visit https://cloud-images.ubuntu.com/locator/ec2/ for more
    eu-central-1 = "ami-056114420b6ed624e" # Frankfurt
    eu-north-1   = "ami-08d18dd6fa8bd7fe6" # Stockholm
    eu-south-1   = "ami-04ae6b3b18f5fa3ea" # Milan
    eu-west-1    = "ami-01aa664a17515f5bb" # Ireland
    eu-west-2    = "ami-0ed4a9453b39ea8c1" # London
    eu-west-3    = "ami-05e451e12993709b7" # Paris
  }
}

variable "PATH_TO_SPARK_MASTER_PUBLIC_KEY" {
  default = "./keys/spark-master-key.pub"
}

variable "PATH_TO_SPARK_WORKER_PUBLIC_KEY" {
  default = "./keys/spark-worker-%02d-key.pub"
}

variable "PATH_TO_SPARK_GATEWAY_PUBLIC_KEY" {
  default = "./keys/spark-gateway-key.pub"
}

variable "PATH_TO_PROM_GRAF_PUBLIC_KEY" {
  default = "./keys/prom-graf-key.pub"
}

variable "PATH_TO_SPARK_MASTER_PRIVATE_KEY" {}
variable "PATH_TO_SPARK_WORKER_PRIVATE_KEY" {}
variable "PATH_TO_SPARK_GATEWAY_PRIVATE_KEY" {}
variable "PATH_TO_PROM_GRAF_PRIVATE_KEY" {}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "INSTANCE_DEVICE_NAME" {
  default = "/dev/xvdh"
}
