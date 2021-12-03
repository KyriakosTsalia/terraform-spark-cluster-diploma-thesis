resource "aws_security_group" "spark-master-securitygroup" {
  vpc_id      = module.vpc.vpc_id # a security group is tied to a VPC
  name        = "spark-master-securitygroup"
  description = "configure ports on spark master for communication between spark master and spark workers"

  # port 7077 for SPARK_MASTER_PORT
  ingress {
    from_port = 7077
    to_port   = 7077
    # communication between the spark master and spark workers happens through rpc;
    # rpc uses http to send json messages; http uses tcp
    protocol = "tcp"
    # only instances within the same vpc should have access;
    # the cidr_block of the vpc is based on the vpc module configuration
    # so instead of having an extra output in the module, we just pass the
    # the variable that configures it
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # port 6066 for SPARK_MASTER_REST_PORT
  ingress {
    from_port = 6066
    to_port   = 6066
    protocol  = "tcp"
    # REST API port - ensure that all network access is restricted to hosts that are trusted to submit jobs
    cidr_blocks = ["0.0.0.0/0"]
  }

  # port 8080 for SPARK_MASTER_WEBUI_PORT
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    # allow access to hosts that are trusted to have access to the WEB UI and all exposed metrics
    cidr_blocks = ["0.0.0.0/0"]
  }

  # all egress traffic is allowed
  egress {
    from_port   = 0    // all ports
    to_port     = 0    // all ports
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spark-master-securitygroup"
  }
}