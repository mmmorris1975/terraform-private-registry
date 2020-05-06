resource "aws_apigatewayv2_route" "get-version" {
  api_id    = var.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/{version}", var.api.base_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.version.id)

  authorizer_id      = var.authorizer_id
  authorization_type = var.authorizer_id != null ? "JWT" : null
}

resource "aws_apigatewayv2_route" "get-version-download" {
  api_id    = var.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/{version}/download", var.api.base_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.version.id)

  authorizer_id      = var.authorizer_id
  authorization_type = var.authorizer_id != null ? "JWT" : null
}

resource "aws_apigatewayv2_integration" "version" {
  api_id                 = var.api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "Terraform registry 'version' resource API routes"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.version.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  timeout_milliseconds   = aws_lambda_function.version.timeout * 1000
}