data "template_file" "init-script-spark-master" {
  template = file("scripts/init.cfg")
  vars = {
    HOSTNAME = "spark-master"
    # to find the private and public IP addresses, we can't use aws_instance.spark-master.private_ip/public_ip,
    # because it creates a cycle in the terraform dependency graph, so we use these "script-like" arguments
    # that will be evaluated at runtime
    # more: 
    # https://unix.stackexchange.com/questions/22615/how-can-i-get-my-external-ip-address-in-a-shell-script/194136#194136
    # https://askubuntu.com/questions/430853/how-do-i-find-my-internal-ip-address/604691#604691
    # (Cycle: 
    #   data.template_file.init-script-spark-master, 
    #   data.template_cloudinit_config.cloudinit-spark-master, 
    #   aws_instance.spark-master
    # )

    # by passing this command as a simple string, it will be passed to the sh shell process to run.
    START_CONTAINER = <<EOF
            docker run -d
                --restart unless-stopped
                --hostname `hostname -I | awk '{print $1}'`
                --name `hostname`-container
                --network host
                --mount type=bind,src=/data,dst=/tmp
                --cpus=1
                --memory=3072m
                -e SPARK_MASTER_HOST=`hostname -I | awk '{print $1}'`
                -e SPARK_LOCAL_IP=`hostname -I | awk '{print $1}'`
                -e SPARK_PUBLIC_DNS=`curl -s http://whatismyip.akamai.com/` 
                ktsaliagkos/spark-master-image
        EOF
  }
}

data "template_file" "init-script-spark-worker" {
  template = file("scripts/init.cfg")
  count    = var.NUMBER_OF_SPARK_WORKERS
  vars = {
    HOSTNAME = format(var.SPARK_WORKER_NAME_FORMAT, count.index)
    # the aws_instance.spark-master.private_ip dictates an explicit dependency between the spark-master 
    # and the spark-worker instances, so this script will start after the spark-master's private_ip is available.        
    START_CONTAINER = <<EOF
            docker run -d
                --restart unless-stopped 
                --hostname `hostname -I | awk '{print $1}'`
                --name `hostname`-container
                --network host
                --mount type=bind,src=/data,dst=/tmp
                -e SPARK_MASTER=spark://${aws_instance.spark-master.private_ip}:7077
                -e SPARK_WORKER_CORES=3
                -e SPARK_WORKER_MEMORY=6G
                -e SPARK_WORKER_HOST=`hostname -I | awk '{print $1}'`
                -e SPARK_LOCAL_IP=`hostname -I | awk '{print $1}'`
                -e SPARK_PUBLIC_DNS=`curl -s http://whatismyip.akamai.com/` 
                ktsaliagkos/spark-worker-image
        EOF
  }
}

data "template_file" "init-script-prom-graf-server" {
  template = file("scripts/init.cfg")
  vars = {
    HOSTNAME        = "prom-graf-server"
    START_CONTAINER = <<EOF
            docker run -d
                --restart unless-stopped
                --hostname prom-container
                --name prom-container
                --network host
                --mount type=bind,src=/data,dst=/prometheus/data
                ktsaliagkos/prometheus-image && 
            docker run -d
                --restart unless-stopped 
                --hostname graf-container
                --name graf-container
                --network host
                -e GF_SECURITY_ADMIN_USER=admin_user
                -e GF_SECURITY_ADMIN_PASSWORD=admin_password
                ktsaliagkos/grafana-image
        EOF
  }
}

data "template_file" "init-script-spark-gateway" {
  template = file("scripts/init.cfg")
  vars = {
    HOSTNAME = "spark-gateway"
    # the spark-gateway container will loop infinitely to stay alive and wait for new application submissions    
    START_CONTAINER = <<EOF
            echo '${aws_instance.spark-master.private_ip} spark-master spark-master' >> /etc/hosts && 
            docker run -d
                --restart unless-stopped 
                --hostname `hostname -I | awk '{print $1}'`
                --name `hostname`-container
                --network host
                --mount type=bind,src=/data,dst=/tmp
                --cpus=3
                --memory=6144m
                -e SPARK_LOCAL_IP=`hostname -I | awk '{print $1}'`
                -e SPARK_PUBLIC_DNS=`curl -s http://whatismyip.akamai.com/`
                -e SPARK_DRIVER_HOST=`hostname -I | awk '{print $1}'`
                ktsaliagkos/spark-base-image
                /bin/bash -c 'trap "exit" TERM; while true; do sleep 1; done'
        EOF
  }
}

data "template_file" "shell-script" {
  template = file("scripts/volumes.sh")
  vars = {
    # the name of the attached device changes; it is not the provided INSTANCE_DEVICE_NAME
    # more:
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
    DEVICE = "/dev/nvme1n1"
  }
}

data "template_cloudinit_config" "cloudinit-spark-master" {
  gzip          = false
  base64_encode = false

  # Parts add files to the generated cloud-init configuration.
  # When multiple parts are added, they will be included in order of declaration.

  # basic instance initialization (update, upgrade, install docker)
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script-spark-master.rendered
  }

  # attach the additional EBS volume
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}

data "template_cloudinit_config" "cloudinit-spark-worker" {
  gzip          = false
  base64_encode = false
  count         = var.NUMBER_OF_SPARK_WORKERS

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script-spark-worker.*.rendered[count.index]
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}

data "template_cloudinit_config" "cloudinit-spark-gateway" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script-spark-gateway.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}

data "template_cloudinit_config" "cloudinit-prom-graf-server" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script-prom-graf-server.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}
