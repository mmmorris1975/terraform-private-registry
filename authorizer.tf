resource "aws_apigatewayv2_authorizer" "jwt" {
  count = var.auth_config == null ? 0 : 1

  api_id           = aws_apigatewayv2_api.api.id
  name             = format("%s-authorizer", aws_apigatewayv2_api.api.name)
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = var.auth_config.audience
    issuer   = var.auth_config.issuer
  }
}