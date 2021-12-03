#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Correct usage: ./deploy-on-aws.sh \${NUM_OF_WORKERS}"
    exit 1
fi

NUM_OF_WORKERS=$1

# configure aws credentials to be able to initialize remote state backend,
# because in the backend definition file (backend.tf) we can't use variables,
# so we need to make sure that terraform can login to aws using the credentials saved by amazon
aws configure

# initialize s3 bucket
cd ./terraform-s3-bucket && \
    terraform init && \ 
    terraform plan -out out.terraform && \
    terraform apply out.terraform && \
    rm out.terraform

# generate keypairs
cd ../terraform-cluster/keys &&  yes "" | ./generate_keypairs.sh ${NUM_OF_WORKERS}

# deploy cluster
cd .. && \
    terraform init && \ # enter aws region when prompted, required by remote state configuration
    terraform plan -out out.terraform && \
    terraform apply out.terraform && \
    rm out.terraform
