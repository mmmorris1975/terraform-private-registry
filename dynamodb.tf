locals {
  dynamodb = merge(var._dynamodb, var.dynamodb)
}

data "aws_kms_key" "dynamodb" {
  key_id = local.dynamodb["kms_key"]
}

resource "aws_dynamodb_table" "db" {
  name = aws_apigatewayv2_api.api.name
  tags = var.tags

  read_capacity  = local.dynamodb["read_capacity"]
  write_capacity = local.dynamodb["write_capacity"]

  hash_key  = "k"
  range_key = "s"

  attribute {
    name = "k"
    type = "S"
  }

  attribute {
    name = "s"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.aws_kms_key.dynamodb.arn
  }

  lifecycle {
    prevent_destroy = local.dynamodb["prevent_destroy"]
  }
}