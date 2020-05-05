variable "auth_config" {
  description = "JWT Authorizer configuration for the API"
  type = object({
    issuer : string
    audience : list(string)
    client_id : string
    authz_endpoint : string
    token_endpoint : string
    ports : list(string)
  })
  default = null
}

variable "dynamodb" {
  type        = map(string)
  description = "Map of dynamodb table attributes to override defaults"
  default     = {}
}

variable "_dynamodb" {
  type        = map(string)
  description = "Default dynamodb table attributes, unless overridden in the 'dynamodb' map"
  default = {
    kms_key        = "alias/aws/dynamodb"
    read_capacity  = 1
    write_capacity = 1
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}