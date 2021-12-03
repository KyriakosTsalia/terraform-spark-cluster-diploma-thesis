resource "aws_security_group" "prom-graf-securitygroup" {
  vpc_id      = module.vpc.vpc_id # a security group is tied to a VPC
  name        = "prom-graf-securitygroup"
  description = "configure ports on prom-graf server for accessing scraped data and viewing grafana visualizations"

  # for prometheus
  ingress {
    from_port = 9090
    to_port   = 9090
    # http protocol uses tcp
    protocol = "tcp"
    # allow access to hosts that are trusted to have access to the WEB UI and all exposed metrics
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0    // all ports
    to_port     = 0    // all ports
    protocol    = "-1" // all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prom-graf-securitygroup"
  }
}