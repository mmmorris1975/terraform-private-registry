terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws = "~> 2.58" # Add many apigatewayv2 resources, will need newer version once fix for #12893 is released
  }
}

locals {
  api             = merge(var._api_config, var.api_config)
  modules_v1_path = "/v1/modules"
}

resource "aws_apigatewayv2_api" "api" {
  name          = local.api["name"]
  description   = "Private Terraform Registry"
  protocol_type = "HTTP"
  tags          = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = module.discovery.route["api_id"]
  name        = "$default"
  description = "Default API Stage, auto-deployed"
  auto_deploy = true
  tags        = var.tags
}