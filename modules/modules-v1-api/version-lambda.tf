locals {
  version_lambda = merge(var._lambda_settings, map("handler", "get_version.lambda_handler"), var.version_lambda_settings)

  version_route_keys = [for e in [
    aws_apigatewayv2_route.get-version.route_key,
    aws_apigatewayv2_route.get-version-download.route_key
  ] : join("", split(" ", e))]

  version_route_arns = [for e in local.version_route_keys : format("%s/*/%s", var.api.execution_arn, e)]
}

resource "aws_lambda_function" "version" {
  function_name = format("%s-version", var.api.name)
  filename      = var.lambda.filename
  handler       = local.version_lambda["handler"]
  memory_size   = local.version_lambda["memory"]
  runtime       = local.version_lambda["runtime"]
  timeout       = local.version_lambda["timeout"]
  role          = var.lambda.role_arn
  tags          = var.tags

  source_code_hash = filebase64sha256(var.lambda.filename)

  environment {
    variables = {
      DOWNLOAD_HOST = ""
      TABLE_NAME    = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_permission" "version" {
  count         = length(local.version_route_arns)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.version.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.version_route_arns[count.index]

  statement_id_prefix = aws_lambda_function.version.function_name
}

resource "aws_cloudwatch_log_group" "version" {
  name              = format("/aws/lambda/%s", aws_lambda_function.version.function_name)
  retention_in_days = local.version_lambda["log_retention_days"]
  tags              = var.tags
}