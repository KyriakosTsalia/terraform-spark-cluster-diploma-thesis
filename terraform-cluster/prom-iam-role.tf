resource "aws_iam_role" "prom-ec2-role" {
  name = "prom-ec2-role"
  # this policy just states that this role will be used for ec2.
  # version is not the version of the policy that we are going to create but a default version set by AWS.
  # from aws docs: "( version_block = "Version" : ("2008-10-17" | "2012-10-17"))"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

# this aws_iam_instance_profile is attached to the aws_iam_role 
# and this is what we refer to in our instance creation
resource "aws_iam_instance_profile" "prom-ec2-role-instanceprofile" {
  name = "prom-ec2-role"
  role = aws_iam_role.prom-ec2-role.name
}
