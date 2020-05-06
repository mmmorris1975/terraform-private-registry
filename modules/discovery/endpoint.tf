resource "aws_apigatewayv2_route" "wkt" {
  api_id    = aws_apigatewayv2_integration.wkt.api_id
  route_key = "GET /.well-known/terraform.json"
  target    = format("integrations/%s", aws_apigatewayv2_integration.wkt.id)
}

resource "aws_apigatewayv2_integration" "wkt" {
  api_id                 = var.api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "Terraform registry service discovery route"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.wkt.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  timeout_milliseconds   = aws_lambda_function.wkt.timeout * 1000
}