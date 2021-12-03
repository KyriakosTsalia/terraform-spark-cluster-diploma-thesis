# NTUA Diploma Thesis: Leveraging Infrastructure as Code and Dynamic Job Scheduling in Cloud Based Distributed Data Processing Systems

My thesis can be found 
<a href="http://artemis.cslab.ece.ntua.gr:8080/jspui/handle/123456789/18204">here</a> (Greek).

This project explores the capabilities of managing immutable infrastructures through code, cloud computing and elasticity in parallel data processing. Firstly, Terraform is used to deploy a dockerized Spark cluster on the AWS EC2 cloud environment and then, based on this infrastructure, experiments can be conducted to comparatively evaluate the different options provided by Spark for dynamic job scheduling. The instances are initialized and customized by cloud-init. The whole cluster is monitored and visualized in real time by a Prometheus/Grafana server. An AWS S3 bucket is separately created to store the Terraform state remotely, as well as application jars and input/output files for Spark applications, and AWS EBS volumes are attached to all instances for additional storage.

The Spark cluster is designed with the standalone client-mode deployment model in mind. Therefore, it includes a spark-master, N spark-workers placed across multiple AWS availability zones in a round-robin fashion and a spark-gateway machine.

## Local test deployments
For test deployments, the `docker-compose.yml` file can be used to spin up a local Spark cluster with 2 spark-workers. The instructions to create and destroy this mini environment are:
```shell
sudo docker-compose --compatibility up --build
sudo docker-compose --compatibility down
```
## Real-world cloud deployments
In order to use this project to deploy infrastructure on the cloud, you need to have Terraform v0.12.24+ and `aws-cli` installed. The latest version of Terraform can be downloaded <a href="https://www.terraform.io/downloads.html">here</a> and `aws-cli` can be installed as follows:
```shell
sudo apt-get update
sudo apt-get install -y awscli
aws version
```
The last command should verify the successful installation.

After cloning the repository, the first step should be to give a new name to the S3 bucket. Each bucket should have a unique name across an AWS region, so it is important to find all occurrences of the bucket name and change it accordingly.\
The bucket name is mentioned in the following files:
* ${PROJECT_ROOT_DIR}/terraform-s3-bucket/main.tf
* ${PROJECT_ROOT_DIR}/terraform-cluster/s3-iam-policy.tf
* ${PROJECT_ROOT_DIR}/terraform-cluster/terraform_config.tf

Next, `terraform.tfvars` files should be created and all variables should be given a value, especially those that don't already have a default value in the `vars.tf` files.

Finally, to deploy on AWS, navigate to the root directory and run the `deploy-on-aws.sh` script. This script will configure your AWS credentials in order to initialize the remote backend and then create the S3 bucket, generate RSA keypairs for the instances and deploy the full cluster. The script will exit when all instances are not only running, but in operable state. It will output the instances' public IP addresses, which can also be found, along with the private ones, in the `cluster_ips.txt` file.

All docker containers run in detached mode. The spark-gateway-container's sole purpose is to wait for applications to be submitted. To submit a spark application through the spark-gateway instance, there are two viable options. The first is to attach to the spark-gateway-container, submit it and then detach using the `CTRL+P,CTRL+Q` sequence. An alternative which doesn't involve attaching to the container, but still gives the ability to view its output, is to copy the submission instruction in a file, e.g. `submit_app.txt`, and then use the following instruction:
```shell
sudo docker exec -i spark-gateway-container /bin/bash -t < submit_app.txt
```

To destroy all deployed infrastructure, run the `destroy-aws-infrastructure.sh` script, which destroys all resources in reverse order of creation and cleans up any secondary local files (keypairs, IP addresses).

---

## License
Copyright &copy; 2021 Kyriakos Tsaliagkos

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
