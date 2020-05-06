module "datastore" {
  source     = "./modules/datastore"
  table_name = aws_apigatewayv2_api.api.name
  tags       = var.tags
}