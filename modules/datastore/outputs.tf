locals {
  output_attr_whitelist = ["id", "arn", "name", "hash_key", "range_key"]
}

output "table" {
  value = { for k, v in aws_dynamodb_table.db : k => v if contains(local.output_attr_whitelist, k) }
}