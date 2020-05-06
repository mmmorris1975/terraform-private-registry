locals {
  output_attr_whitelist = ["id", "arn", "name", "api_id", "route_key"]
}

output "provider_routes" {
  value = {
    get_latest = {
      for k, v in aws_apigatewayv2_route.get-provider : k => v if contains(local.output_attr_whitelist, k)
    }

    get_versions = {
      for k, v in aws_apigatewayv2_route.get-provider-versions : k => v if contains(local.output_attr_whitelist, k)
    }

    get_download = {
      for k, v in aws_apigatewayv2_route.get-version-download : k => v if contains(local.output_attr_whitelist, k)
    }
  }
}

output "version_routes" {
  value = {
    get_version = {
      for k, v in aws_apigatewayv2_route.get-version : k => v if contains(local.output_attr_whitelist, k)
    }

    get_download = {
      for k, v in aws_apigatewayv2_route.get-version-download : k => v if contains(local.output_attr_whitelist, k)
    }
  }
}