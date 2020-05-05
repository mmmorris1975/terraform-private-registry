locals {
  wkt_item = {
    "${aws_dynamodb_table.db.hash_key}" : {
      S : "wkt"
    }
    "${aws_dynamodb_table.db.range_key}" : {
      S : "cfg"
    }
    "modules_v1" : {
      S : local.module_path
    }
    "login_v1" : {
      M : {
        "grant_types" : {
          SS : [
          "authz_code"]
        }
        "client" : can(var.auth_config.client_id) ? {
          S : var.auth_config.client_id
          } : {
          NULL : true
        }
        "authz" : can(var.auth_config.authz_endpoint) ? {
          S : var.auth_config.authz_endpoint
          } : {
          NULL : true
        }
        "token" : can(var.auth_config.token_endpoint) ? {
          S : var.auth_config.token_endpoint
          } : {
          NULL : true
        }
        "ports" : can(var.auth_config.ports) ? {
          NS : var.auth_config.ports
          } : {
          NS : [
          "-1"]
        }
      }
    }
  }
}

resource "aws_dynamodb_table_item" "wkt" {
  table_name = aws_dynamodb_table.db.name
  hash_key   = aws_dynamodb_table.db.hash_key
  range_key  = aws_dynamodb_table.db.range_key
  item       = jsonencode(local.wkt_item)
}