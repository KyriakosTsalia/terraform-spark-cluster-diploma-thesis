resource "aws_security_group" "allow-ssh-ping" {
  vpc_id      = aws_vpc.main.id # a security group is tied to a VPC
  name        = "allow-ssh-ping"
  description = "allow SSH, ping and all egress traffic"

  ingress {
    from_port   = 22            // only allow access to port 22
    to_port     = 22            // SSH uses port 22
    protocol    = "tcp"         // SSH only needs TCP access
    cidr_blocks = ["0.0.0.0/0"] // all IP addresses - best to restrict to certain IP addresses, i.e. office, home
  }

  # allow ping - ping uses the icmp protocol, which actually uses no ports(!)
  # more here: https://blog.jwr.io/terraform/icmp/ping/security/groups/2018/02/02/terraform-icmp-rules.html
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0             // all ports
    to_port     = 0             // all ports
    protocol    = "-1"          // all protocols
    cidr_blocks = ["0.0.0.0/0"] // all IP addresses
  }

  tags = {
    Name = "allow-ssh-ping"
  }
}