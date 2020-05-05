locals {
  provider_route_keys = [for e in [
    aws_apigatewayv2_route.get-provider.route_key,
    aws_apigatewayv2_route.get-provider-versions.route_key,
    aws_apigatewayv2_route.get-provider-download.route_key
  ] : join("", split(" ", e))]

  provider_route_arns = [for e in local.provider_route_keys : format("%s/*/%s", aws_apigatewayv2_api.api.execution_arn, e)]
}

resource "aws_apigatewayv2_route" "get-provider" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}", local.module_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorization_type = local.auth_type
  authorizer_id      = local.auth_id
}

resource "aws_apigatewayv2_route" "get-provider-versions" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/versions", local.module_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorization_type = local.auth_type
  authorizer_id      = local.auth_id
}

resource "aws_apigatewayv2_route" "get-provider-download" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = format("GET %s/{namespace}/{name}/{provider}/download", local.module_path)
  target    = format("integrations/%s", aws_apigatewayv2_integration.provider.id)

  authorization_type = local.auth_type
  authorizer_id      = local.auth_id
}

resource "aws_apigatewayv2_integration" "provider" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  // maybe just AWS?
  connection_type        = "INTERNET"
  description            = ""
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.provider.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  timeout_milliseconds   = aws_lambda_function.provider.timeout * 1000
}