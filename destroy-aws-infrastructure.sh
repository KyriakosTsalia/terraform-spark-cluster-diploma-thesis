cd ./terraform-cluster
# terminate all VMs
terraform destroy # enter 'yes' when prompted
# clear cluster_ips.txt
> cluster_ips.txt
# delete all generated keypairs
rm ./keys/spark-* ./keys/prom-graf-*

cd ../terraform-s3-bucket
# destroy S3 bucket
terraform destroy # enter 'yes' when prompted
cd ..