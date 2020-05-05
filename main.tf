terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = ">= 2.58.0"
    # Add many apigatewayv2 resources, will need newer version once fix for #12893 is released
  }
}

locals {
  auth_type   = var.auth_config == null ? "NONE" : aws_apigatewayv2_authorizer.jwt[0].authorizer_type
  auth_id     = local.auth_type == "JWT" ? aws_apigatewayv2_authorizer.jwt[0].id : null
  module_path = "/v1/modules"
}

resource "aws_apigatewayv2_api" "api" {
  name          = "terraform-registry"
  description   = "Private Terraform Registry"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_route.wkt.api_id
  name        = "$default"
  description = "Default API Stage, auto-deployed"
  auto_deploy = true
  tags        = var.tags
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  count = var.auth_config == null ? 0 : 1

  api_id          = aws_apigatewayv2_api.api.id
  name            = format("%s-authorizer", aws_apigatewayv2_api.api.name)
  authorizer_type = "JWT"
  identity_sources = [
  "$request.header.Authorization"]

  jwt_configuration {
    audience = var.auth_config.audience
    issuer   = var.auth_config.issuer
  }
}