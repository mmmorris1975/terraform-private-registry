# Module Registry Discovery API

Build the AWS HTTP API gateway endpoint for the required Terraform registry
[service discovery](https://www.terraform.io/docs/internals/remote-service-discovery.html)

## Example
```hcl-terraform
module "discovery" {
  source = "path/to/terraform-registry//modules/discovery"

  api = {
    id   = "MyApiId"
    name = "MyApiName"
    execution_arn = "arn:aws:execute-api:us-east-1:1234567890:MyApiId"
  }

  lambda = {
    filename = "path/to/lambda.zip"
    role_arn = "arn:aws:iam::1234567890:role/terraform-registry-lambda"
  }

  dynamodb_table_name = module.datastore.table["name"]
}
```

## Input Variables

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| api | API gateway properties | **Y** | |
| lambda | Lambda function required properties | **Y** | |
| dynamodb_table_name | DynamoDB table name for lambda function | **Y** | |
| tags | The map of tags to apply to taggable resources | N | empty map |
| lambda_settings | Configuration settings for the Lambda function | N | empty map |

### lambda_settings Variable Default Values

| Name | Description | Value |
|------|-------------|-------|
| timeout | The function execution timeout, in seconds| 3 |
| memory | The function memory setting, in MiB | 128 |
| runtime | The function runtime | python3.8 |
| handler | The function handler name | wkt.lambda_handler |

## Output Variables

A filtered map of properties for the API Gateway route resource.  Exposed map keys are:
  * id
  * arn
  * name
  * api_id
  * route_key