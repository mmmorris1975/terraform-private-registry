resource "aws_lambda_function" "wkt" {
  function_name = format("%s-wkt", aws_apigatewayv2_api.api.name)
  filename      = "lambda.${null_resource.build.triggers["id"]}.zip"
  handler       = "wkt.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda.arn
  timeout       = 3
  memory_size   = 128
  tags          = var.tags

  source_code_hash = filebase64sha256("lambda.${null_resource.build.triggers["id"]}.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.db.name
    }
  }
}

resource "aws_lambda_permission" "wkt" {
  count         = length(local.wkt_route_arns)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wkt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.wkt_route_arns[count.index]

  statement_id_prefix = aws_lambda_function.wkt.function_name
}

resource "aws_cloudwatch_log_group" "wkt" {
  name              = format("/aws/lambda/%s", aws_lambda_function.wkt.function_name)
  retention_in_days = 30
  tags              = var.tags
}