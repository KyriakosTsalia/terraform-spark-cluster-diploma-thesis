resource "aws_instance" "spark-master" {
  # Amazon Machine Image - AMI - to create a VM within the AWS EC2
  ami = lookup(var.AMIS, var.AWS_REGION)

  # instance type
  instance_type = var.SPARK_MASTER_INSTANCE_TYPE

  # VPC subnet - place an instance in a public VPC subnet in round-robin fashion
  subnet_id = element(module.vpc.public_subnets, 0)

  # security groups - one or more
  vpc_security_group_ids = [
    module.vpc.security_group_id,
    aws_security_group.spark-master-securitygroup.id
  ]

  # public SSH key
  key_name = aws_key_pair.spark-master-key.key_name

  # executed at the creation of the instance, not when it reboots
  user_data = data.template_cloudinit_config.cloudinit-spark-master.rendered

  # iam instance role - this is how the instance will access our s3 bucket
  iam_instance_profile = aws_iam_instance_profile.s3-bucket-access-role-instanceprofile.name

  # with the local-exec provisioner, after the instance is created (but not necessarily in operable state),
  # an executable will be invoked in the local machine
  provisioner "local-exec" {
    command = "echo 'spark-master-public_ip ${self.public_ip}\nspark-master-private_ip ${self.private_ip}\n' >> cluster_ips.txt"
  }

  tags = {
    Name = "spark-master"
  }
}

resource "aws_ebs_volume" "ebs-volume-spark-master" {
  availability_zone = "${var.AWS_REGION}a"
  size              = 20    # GB
  type              = "gp2" # General Purpose Storage - SSD 

  tags = {
    Name = "additional data volume for spark-master"
  }
}

resource "aws_volume_attachment" "ebs-volume-spark-master-attachment" {
  device_name = var.INSTANCE_DEVICE_NAME
  volume_id   = aws_ebs_volume.ebs-volume-spark-master.id
  instance_id = aws_instance.spark-master.id

  skip_destroy = true # to avoid issues with terraform destroy, do not detach the volume
  # from the instance to which it is attached at destroy time, instead just remove
  # the attachment from terraform state.                       
}

resource "null_resource" "spark-master-null" {
  # configure SSH connection
  connection {
    host        = coalesce(aws_instance.spark-master.public_ip, aws_instance.spark-master.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PATH_TO_SPARK_MASTER_PRIVATE_KEY)
  }
  provisioner "remote-exec" {
    # use the 'END' as a signal that the instance is ready
    inline = [
      "#!/bin/bash\nwhile [[ ! ( $(tail -n 1 /var/log/cloud-init-output.log) = 'END' ) ]]\ndo\nsleep 1\ndone"
    ]
  }
}

# output the public ip of the newly created instance
output "spark-master-public_ip" {
  value = aws_instance.spark-master.public_ip
}