locals {
  output_attr_whitelist = ["id", "arn", "name", "api_id", "route_key"]
}

output "route" {
  value = { for k, v in aws_apigatewayv2_route.wkt : k => v if contains(local.output_attr_whitelist, k) }
}