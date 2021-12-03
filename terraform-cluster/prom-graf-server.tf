resource "aws_instance" "prom-graf-server" {
  # Amazon Machine Image - AMI - to create a VM within the AWS EC2
  ami = lookup(var.AMIS, var.AWS_REGION)

  # instance type
  instance_type = var.PROM_GRAF_SERVER_INSTANCE_TYPE

  # VPC subnet - place an instance in a public VPC subnet in round-robin fashion
  subnet_id = element(module.vpc.public_subnets, 0)

  # security groups - one or more
  vpc_security_group_ids = [
    module.vpc.security_group_id,
    aws_security_group.prom-graf-securitygroup.id
  ]

  # public SSH key
  key_name = aws_key_pair.prom-graf-key.key_name

  # executed at the creation of the instance, not when it reboots
  user_data = data.template_cloudinit_config.cloudinit-prom-graf-server.rendered

  # iam instance role - this is how the instance will scrape the spark prometheus endpoints
  iam_instance_profile = aws_iam_instance_profile.prom-ec2-role-instanceprofile.name

  # with the local-exec provisioner, after the instance is created (but not necessarily in operable state),
  # an executable will be invoked in the local machine
  provisioner "local-exec" {
    command = "echo 'prom-graf-server-public_ip ${self.public_ip}\nprom-graf-server-private_ip ${self.private_ip}\n' >> cluster_ips.txt"
  }

  tags = {
    Name = "prom-graf-server"
  }
}

resource "aws_ebs_volume" "ebs-volume-prom-graf-server" {
  availability_zone = "${var.AWS_REGION}a"
  size              = 20    # GB
  type              = "gp2" # General Purpose Storage - SSD 

  tags = {
    Name = "additional data volume for prom-graf-server"
  }
}

resource "aws_volume_attachment" "ebs-volume-prom-graf-server-attachment" {
  device_name = var.INSTANCE_DEVICE_NAME
  volume_id   = aws_ebs_volume.ebs-volume-prom-graf-server.id
  instance_id = aws_instance.prom-graf-server.id

  skip_destroy = true # to avoid issues with terraform destroy, do not detach the volume
  # from the instance to which it is attached at destroy time, instead just remove
  # the attachment from terraform state.                      
}

resource "null_resource" "prom-graf-null" {
  # configure SSH connection
  connection {
    host        = coalesce(aws_instance.prom-graf-server.public_ip, aws_instance.prom-graf-server.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PATH_TO_PROM_GRAF_PRIVATE_KEY)
  }
  provisioner "remote-exec" {
    # use the 'END' as a signal that the instance is ready
    inline = [
      "#!/bin/bash\nwhile [[ ! ( $(tail -n 1 /var/log/cloud-init-output.log) = 'END' ) ]]\ndo\nsleep 1\ndone"
    ]
  }
}

# output the public ip of the newly created instance
output "prom-graf-server-public_ip" {
  value = aws_instance.prom-graf-server.public_ip
}