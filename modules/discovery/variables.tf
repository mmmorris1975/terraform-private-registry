variable "api" {
  description = "API gateway properties"
  type = object({
    id : string
    name : string
    execution_arn : string
  })
}

variable "lambda" {
  description = "Lambda function required properties"
  type = object({
    filename : string
    role_arn : string
  })
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for lambda function"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "lambda_settings" {
  type        = map(string)
  description = "Configuration settings for the Lambda function"
  default     = {}
}

variable "_lambda_settings" {
  type        = map(string)
  description = "Default settings for the Lambda function, unless overridden in the 'lambda_settings' variable"

  default = {
    timeout = 3
    memory  = 128
    runtime = "python3.8"
    handler = "wkt.lambda_handler"

    log_retention_days = 30
  }
}