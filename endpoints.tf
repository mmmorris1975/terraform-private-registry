locals {
  api_properties = {
    id            = aws_apigatewayv2_api.api.id
    name          = aws_apigatewayv2_api.api.name
    execution_arn = aws_apigatewayv2_api.api.execution_arn
  }

  lambda_properties = {
    filename = "${path.module}/${null_resource.build.triggers.id}"
    role_arn = aws_iam_role.lambda.arn
  }
}

module "discovery" {
  source = "./modules/discovery"

  api    = local.api_properties
  lambda = local.lambda_properties

  dynamodb_table_name = module.datastore.table["name"]
  tags                = var.tags
}

module "modules_v1" {
  source = "./modules/modules-v1-api"

  api    = merge(local.api_properties, map("base_path", local.api["modules_v1_path"]))
  lambda = local.lambda_properties

  authorizer_id       = var.auth_config != null ? aws_apigatewayv2_authorizer.jwt[0].id : null
  dynamodb_table_name = module.datastore.table["name"]
  tags                = var.tags
}