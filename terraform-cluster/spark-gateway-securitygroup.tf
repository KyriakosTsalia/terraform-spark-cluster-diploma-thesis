resource "aws_security_group" "spark-gateway-securitygroup" {
  vpc_id      = module.vpc.vpc_id # a security group is tied to a VPC
  name        = "spark-gateway-securitygroup"
  description = "configure ports on spark gateway for communication between the spark driver and spark master/workers"

  # ports 22200-22215 for SPARK_DRIVER_PORT, giving a MAXIMUM of 16 1-core drivers,
  # thus a MAXIMUM of 16 concurrent spark applications, since the spark.port.maxRetries is set at the default value 16
  ingress {
    from_port = 22200
    to_port   = 22215
    protocol  = "tcp" // for http
    # only instances within the same vpc should have access;
    # the cidr_block of the vpc is based on the vpc module configuration
    # so instead of having an extra output in the module, we just pass the
    # the variable that configures it
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # ports 55500-55515 for SPARK_DRIVER_BLOCKMANAGER_PORT, for the same reason as above
  ingress {
    from_port   = 55500
    to_port     = 55515
    protocol    = "tcp"
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # ports 33300-33315 for SPARK_BLOCKMANAGER_PORT, for the same reason as above
  ingress {
    from_port   = 33300
    to_port     = 33315
    protocol    = "tcp"
    cidr_blocks = [var.IP_RANGE_FOR_VPC_MODULE]
  }

  # ports 4040-4055 for SPARK_DRIVER_UI_PORT, for spark-driver UI and prometheus metrics, for the same reason as above
  ingress {
    from_port = 4040
    to_port   = 4055
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
    Name = "spark-gateway-securitygroup"
  }
}