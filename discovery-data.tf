locals {
  wkt_item = {
    "${module.datastore.table["hash_key"]}" : { S : "wkt" }
    "${module.datastore.table["range_key"]}" : { S : "cfg" }
    "modules_v1" : { S : local.modules_v1_path }
    "login_v1" : {
      M : {
        "grant_types" : { SS : ["authz_code"] }
        "client" : can(var.auth_config.client_id) ? { S : var.auth_config.client_id } : { NULL : true }
        "authz" : can(var.auth_config.authz_endpoint) ? { S : var.auth_config.authz_endpoint } : { NULL : true }
        "token" : can(var.auth_config.token_endpoint) ? { S : var.auth_config.token_endpoint } : { NULL : true }
        "ports" : can(var.auth_config.ports) ? { NS : var.auth_config.ports } : { NS : ["-1"] }
      }
    }
  }
}

resource "aws_dynamodb_table_item" "wkt" {
  table_name = module.datastore.table["name"]
  hash_key   = module.datastore.table["hash_key"]
  range_key  = module.datastore.table["range_key"]
  item       = jsonencode(local.wkt_item)
}