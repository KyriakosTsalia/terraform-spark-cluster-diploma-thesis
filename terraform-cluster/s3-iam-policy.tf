# with the aws_iam_role_policy we can give permissions to our role
resource "aws_iam_role_policy" "s3-bucket-access-role-policy" {
  name = "s3-bucket-access-role-policy"
  role = aws_iam_role.s3-bucket-access-role.id
  # we allow ("Allow") all s3 actions ("s3:*")
  # either ON the bucket ("terraform-spark-cluster") or IN the bucket ("terraform-spark-cluster/*")
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-spark-cluster",
        "arn:aws:s3:::terraform-spark-cluster/*"
      ]
    }
  ]
}
EOF

}