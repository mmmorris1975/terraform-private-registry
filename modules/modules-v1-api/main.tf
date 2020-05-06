terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = "~> 2.58" # Add aws_apigatewayv2_route resource
  }
}

locals {
  authorization_type = var.authorizer_id != null ? "JWT" : null
}