resource "aws_apigatewayv2_route" "get-provider" {
  api_id    = var.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}", var.api.base_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorizer_id      = var.authorizer_id
  authorization_type = local.authorization_type
}

resource "aws_apigatewayv2_route" "get-provider-versions" {
  api_id    = var.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/versions", var.api.base_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorizer_id      = var.authorizer_id
  authorization_type = local.authorization_type
}

resource "aws_apigatewayv2_route" "get-provider-download" {
  api_id    = var.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/download", var.api.base_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorizer_id      = var.authorizer_id
  authorization_type = local.authorization_type
}

resource "aws_apigatewayv2_integration" "provider" {
  api_id                 = var.api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "Terraform registry 'provider' resource API routes"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.provider.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  timeout_milliseconds   = aws_lambda_function.provider.timeout * 1000
}