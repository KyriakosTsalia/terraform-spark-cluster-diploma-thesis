resource "aws_instance" "spark-worker" {
  // total number of instances - spark-worker will be an ARRAY of instances
  count = var.NUMBER_OF_SPARK_WORKERS

  # Amazon Machine Image - AMI - to create a VM within the AWS EC2
  ami = lookup(var.AMIS, var.AWS_REGION)

  # instance type
  instance_type = var.SPARK_WORKER_INSTANCE_TYPE

  # VPC subnet - place an instance in a public VPC subnet in round-robin fashion
  subnet_id = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))

  # security groups - one or more
  vpc_security_group_ids = [
    module.vpc.security_group_id,
    aws_security_group.spark-worker-securitygroup.id
  ]

  # public SSH key
  key_name = aws_key_pair.spark-worker-key[count.index].key_name

  # executed at the creation of the instance, not when it reboots
  user_data = element(data.template_cloudinit_config.cloudinit-spark-worker.*.rendered, count.index)

  # iam instance role - this is how the instance will access our s3 bucket
  iam_instance_profile = aws_iam_instance_profile.s3-bucket-access-role-instanceprofile.name

  # with the local-exec provisioner, after the instance is created (but not necessarily in operable state),
  # an executable will be invoked in the local machine
  # the use of the 'self' object here refers to the current resource instance, not the resource block as a whole
  provisioner "local-exec" {
    command = "echo '${format(var.SPARK_WORKER_NAME_FORMAT, count.index)}-public_ip ${self.public_ip}\n${format(var.SPARK_WORKER_NAME_FORMAT, count.index)}-private_ip ${self.private_ip}\n' >> cluster_ips.txt"
  }


  tags = {
    Name = format(var.SPARK_WORKER_NAME_FORMAT, count.index)
  }
}

resource "aws_ebs_volume" "ebs-volume-spark-worker" {
  count = var.NUMBER_OF_SPARK_WORKERS

  # 0 1 2 3 4 5 6 ...
  # a b c a b c a ...
  availability_zone = "${var.AWS_REGION}${count.index % length(module.vpc.public_subnets) == 0 ? "a" : (count.index % length(module.vpc.public_subnets) == 1 ? "b" : "c")}"
  size              = 80    # GB
  type              = "gp2" # General Purpose Storage - SSD 

  tags = {
    Name = "additional data volume for ${format(var.SPARK_WORKER_NAME_FORMAT, count.index)}"
  }
}

resource "aws_volume_attachment" "ebs-volume-spark-worker-attachment" {
  count       = var.NUMBER_OF_SPARK_WORKERS
  device_name = var.INSTANCE_DEVICE_NAME
  volume_id   = element(aws_ebs_volume.ebs-volume-spark-worker.*.id, count.index)
  instance_id = element(aws_instance.spark-worker.*.id, count.index)

  skip_destroy = true # to avoid issues with terraform destroy, do not detach the volume
  # from the instance to which it is attached at destroy time, instead just remove
  # the attachment from terraform state.                    
}

resource "null_resource" "spark-worker-null" {
  count = var.NUMBER_OF_SPARK_WORKERS
  # configure SSH connection
  connection {
    host        = coalesce(element(aws_instance.spark-worker.*.public_ip, count.index), element(aws_instance.spark-worker.*.private_ip, count.index))
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(format(var.PATH_TO_SPARK_WORKER_PRIVATE_KEY, count.index))
  }
  provisioner "remote-exec" {
    # use the 'END' as a signal that the instance is ready
    inline = [
      "#!/bin/bash\nwhile [[ ! ( $(tail -n 1 /var/log/cloud-init-output.log) = 'END' ) ]]\ndo\nsleep 1\ndone"
    ]
  }
}

# output the public ip of the newly created instance
output "spark-worker-public_ip" {
  value = aws_instance.spark-worker.*.public_ip
}