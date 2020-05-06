variable "table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the DynamoDB resources"
  default     = {}
}

variable "kms_key" {
  type        = string
  description = "KMS key for DynamoDB table encryption"
  default     = "alias/aws/dynamodb"
}

variable "capacity" {
  type        = map(number)
  description = "A map of the read and write capacity settings for the DynamoDB table"
  default     = {}
}

variable "_capacity" {
  type        = map(number)
  description = "Default table read and write capacity settings, unless overridden by the 'capacity' variable"

  default = {
    read  = 1
    write = 1
  }
}