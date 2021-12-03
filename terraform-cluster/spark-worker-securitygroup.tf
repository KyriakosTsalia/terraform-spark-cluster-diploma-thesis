resource "aws_security_group" "spark-worker-securitygroup" {
  vpc_id      = module.vpc.vpc_id # a security group is tied to a VPC
  name        = "spark-worker-securitygroup"
  description = "configure ports on spark workers for communication between spark master and spark workers"

  # port 44444 for SPARK_WORKER_PORT
  ingress {
    from_port = 44444
    to_port   = 44444
    # communication between the spark master and spark workers happens through rpc;
    # rpc uses http to send json messages; http uses tcp
    protocol = "tcp"
    # only instances within the same vpc should have access;
    # the cidr_block of the vpc is based on the vpc module configuration
    # so instead of having an extra output in the module, we just pass the
    # the variable that configures it
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # port 7337 for SPARK_EXTERNAL_SHUFFLE_SERVICE_PORT
  ingress {
    from_port   = 7337
    to_port     = 7337
    protocol    = "tcp"
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # port 8081 for SPARK_WORKER_WEBUI_PORT
  ingress {
    from_port = 8081
    to_port   = 8081
    protocol  = "tcp"
    # allow access to hosts that are trusted to have access to the WEB UI and all exposed metrics
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ports 33300-33315 for SPARK_BLOCKMANAGER_PORT, giving a MAXIMUM of 16 1-core executors,
  # since the spark.port.maxRetries is set at the default value 16
  ingress {
    from_port   = 33300
    to_port     = 33315
    protocol    = "tcp"
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # all egress traffic is allowed
  egress {
    from_port   = 0    // all ports
    to_port     = 0    // all ports
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spark-worker-securitygroup"
  }
}