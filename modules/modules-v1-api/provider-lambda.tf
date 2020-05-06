locals {
  provider_lambda = merge(var._lambda_settings, map("handler", "get_provider.lambda_handler"), var.provider_lambda_settings)

  provider_route_keys = [for e in [
    aws_apigatewayv2_route.get-provider.route_key,
    aws_apigatewayv2_route.get-provider-versions.route_key,
    aws_apigatewayv2_route.get-provider-download.route_key
  ] : join("", split(" ", e))]

  provider_route_arns = [for e in local.provider_route_keys : format("%s/*/%s", var.api.execution_arn, e)]
}

resource "aws_lambda_function" "provider" {
  function_name = format("%s-provider", var.api.name)
  filename      = var.lambda.filename
  handler       = local.provider_lambda["handler"]
  memory_size   = local.provider_lambda["memory"]
  runtime       = local.provider_lambda["runtime"]
  timeout       = local.provider_lambda["timeout"]
  role          = var.lambda.role_arn
  tags          = var.tags

  source_code_hash = filebase64sha256(var.lambda.filename)

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_permission" "provider" {
  count         = length(local.provider_route_arns)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.provider.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.provider_route_arns[count.index]

  statement_id_prefix = aws_lambda_function.provider.function_name
}

resource "aws_cloudwatch_log_group" "provider" {
  name              = format("/aws/lambda/%s", aws_lambda_function.provider.function_name)
  retention_in_days = local.provider_lambda["log_retention_days"]
  tags              = var.tags
}