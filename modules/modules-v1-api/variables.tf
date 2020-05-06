variable "api" {
  description = "API gateway properties"
  type = object({
    id : string
    name : string
    execution_arn : string
    base_path : string
  })
}

variable "lambda" {
  description = "Common Lambda function required properties"
  type = object({
    filename : string
    role_arn : string
  })
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for lambda function"
}

variable "authorizer_id" {
  type        = string
  description = "ID of the API authorizer resource, applies to all endpoints in the module"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "The map of tags to apply to taggable resources"
  default     = {}
}

variable "provider_lambda_settings" {
  type        = map(string)
  description = "Configuration settings for the provider API resource Lambda function"
  default     = {}
}

variable "version_lambda_settings" {
  type        = map(string)
  description = "Configuration settings for the version API resource Lambda function"
  default     = {}
}

variable "_lambda_settings" {
  type        = map(string)
  description = "Default settings for all Lambda functions, unless overridden in the '*_lambda_settings' variables"

  default = {
    timeout = 3
    memory  = 128
    runtime = "python3.8"
    handler = ""

    log_retention_days = 30
  }
}