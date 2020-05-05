resource "aws_lambda_function" "version" {
  function_name = format("%s-version", aws_apigatewayv2_api.api.name)
  filename      = "lambda.${null_resource.build.triggers["id"]}.zip"
  handler       = "get_version.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda.arn
  timeout       = 3
  memory_size   = 128
  tags          = var.tags

  source_code_hash = filebase64sha256("lambda.${null_resource.build.triggers["id"]}.zip")

  environment {
    variables = {
      DOWNLOAD_HOST = ""
      TABLE_NAME    = aws_dynamodb_table.db.name
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
  retention_in_days = 30
  tags              = var.tags
}