locals {
  output_attr_whitelist = ["id", "arn", "name"]
}

output "api_gateway" {
  value = {
    for k, v in aws_apigatewayv2_api.api : k => v if contains(concat(local.output_attr_whitelist, ["api_endpoint", "execution_arn"]), k)
  }
}

output "authorizer" {
  value = var.auth_config == null ? {} : {
    for k, v in aws_apigatewayv2_authorizer.jwt[0] : k => v if contains(local.output_attr_whitelist, k)
  }
}

output "lambda_iam_role" {
  value = { for k, v in aws_iam_role.lambda : k => v if contains(local.output_attr_whitelist, k) }
}

output "datasource" { value = module.datastore.table }
output "discovery-api" { value = module.discovery.route }
output "modules_v1" { value = module.modules_v1 }