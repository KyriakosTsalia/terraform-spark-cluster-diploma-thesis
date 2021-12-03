provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

resource "aws_s3_bucket" "terraform_state_and_app_jars" {
  # name must be unique - change accordingly but keep track!
  bucket = "terraform-spark-cluster"

  # to be able to destroy the bucket without having to manually delete everything inside it first
  force_destroy = true

  # enable versioning to see the full revision history of our state files
  versioning {
    enabled = true
  }

  # enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Spark cluster terraform state and application jars"
  }
}