# Module Registry DynamoDB Datastore

Build the DynamoDB table used to store module metadata for the registry.  By default, the table is encrypted using the
service default KMS key and a default provisioned read and write capacity of 1.

## Example
```hcl-terraform
module "datastore" {
  source     = "path/to/terraform-registry//modules/datastore"
  table_name = "my-table"
}
```

## Input Variables

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| table_name | DynamoDB table name | **Y** | |
| tags | The map of tags to apply to taggable resources | N | empty map |
| kms_key | The KMS key used to encrypt the table | N | alias/aws/dynamodb |
| capacity | A map of the read and write capacity settings for the DynamoDB table | N | empty map |

### capacity Variable Default Values

| Name | Description | Value |
|------|-------------|-------|
| read | The table provisioned read capacity | 1 |
| write | The table provisioned write capacity | 1 |

## Output Variables

A filtered map of properties for the DynamoDB table resource.  Exposed map keys are:
  * id
  * arn
  * name
  * hash_key
  * range_key