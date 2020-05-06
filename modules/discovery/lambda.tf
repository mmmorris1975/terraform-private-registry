locals {
  wkt_route_arn = format("%s/*/%s", var.api.execution_arn,
    join("", split(" ", aws_apigatewayv2_route.wkt.route_key))
  )

  lambda = merge(var._lambda_settings, var.lambda_settings)
}

resource "aws_lambda_function" "wkt" {
  function_name = format("%s-wkt", var.api.name)
  filename      = var.lambda.filename
  handler       = local.lambda["handler"]
  memory_size   = local.lambda["memory"]
  runtime       = local.lambda["runtime"]
  timeout       = local.lambda["timeout"]
  role          = var.lambda.role_arn
  tags          = var.tags

  source_code_hash = filebase64sha256(var.lambda.filename)

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_permission" "wkt" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wkt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.wkt_route_arn

  statement_id_prefix = aws_lambda_function.wkt.function_name
}

resource "aws_cloudwatch_log_group" "wkt" {
  name = format("/aws/lambda/%s", aws_lambda_function.wkt.function_name)
  tags = var.tags

  retention_in_days = local.lambda["log_retention_days"]
}