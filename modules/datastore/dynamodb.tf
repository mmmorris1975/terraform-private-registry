locals {
  capacity  = merge(var._capacity, var.capacity)
  hash_key  = "k"
  range_key = "s"
}

data "aws_kms_key" "dynamodb" {
  key_id = var.kms_key
}

resource "aws_dynamodb_table" "db" {
  name = var.table_name
  tags = var.tags

  read_capacity  = local.capacity["read"]
  write_capacity = local.capacity["write"]

  hash_key  = local.hash_key
  range_key = local.range_key

  attribute {
    name = local.hash_key
    type = "S"
  }

  attribute {
    name = local.range_key
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = data.aws_kms_key.dynamodb.arn
  }
}