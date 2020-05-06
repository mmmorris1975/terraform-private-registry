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

variable "api_config" {
  type        = map(string)
  description = ""
  default     = {}
}

variable "_api_config" {
  type        = map(string)
  description = ""
  default = {
    name            = "terraform-registry"
    modules_v1_path = "/v1/modules"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}