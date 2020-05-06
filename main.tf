terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = "~> 2.58" # Add many apigatewayv2 resources, will need newer version once fix for #12893 is released
  }
}

locals {
  modules_v1_path = "/v1/modules"
  api             = merge(var._api_config, var.api_config)
}

resource "aws_apigatewayv2_api" "api" {
  name          = local.api["name"]
  description   = "Private Terraform Registry"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  #api_id      = aws_apigatewayv2_route.wkt.api_id
  api_id      = module.discovery.route["api_id"]
  name        = "$default"
  description = "Default API Stage, auto-deployed"
  auto_deploy = true
  tags        = var.tags
}