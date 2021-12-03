# output everything that will be needed/referenced in the usage of this module
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.main-public[*].id
}

output "private_subnets" {
  value = aws_subnet.main-private[*].id
}

output "security_group_id" {
  value = aws_security_group.allow-ssh-ping.id
}