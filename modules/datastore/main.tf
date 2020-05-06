terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = "~> 2.47" # Add server_side_encryption configuration block kms_key_arn argument to aws_dynamodb_table
  }
}