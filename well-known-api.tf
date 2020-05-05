locals {
  wkt_route_keys = [for e in [
    aws_apigatewayv2_route.wkt.route_key
  ] : join("", split(" ", e))]

  wkt_route_arns = [for e in local.wkt_route_keys : format("%s/*/%s", aws_apigatewayv2_api.api.execution_arn, e)]
}

resource "aws_apigatewayv2_route" "wkt" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /.well-known/terraform.json"
  target    = format("integrations/%s", aws_apigatewayv2_integration.wkt.id)
}

resource "aws_apigatewayv2_integration" "wkt" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  // maybe just AWS?
  connection_type        = "INTERNET"
  description            = ""
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.wkt.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
  timeout_milliseconds   = aws_lambda_function.wkt.timeout * 1000
}