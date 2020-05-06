# Module Registry API

Build the AWS HTTP API gateway endpoints which implement a subset of the Terraform Registry
(HTTP API)[https://www.terraform.io/docs/registry/api.html] which is required for the Terraform CLI to interact with
the private registry.

The module supports configuring an Authorizer against the endpoints managed by this module so that the interaction with
the registry is authenticated. By default, these endpoints are unauthenticated.

## Example
```hcl-terraform
module "modules_v1" {
  source = "path/to/terraform-registry//modules/modules-v1-api"

  api    = {
    id   = "MyApiId"
    name = "MyApiName"
    execution_arn = "arn:aws:execute-api:us-east-1:1234567890:MyApiId"
    base_path     = "/v1/modules"
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
| authorizer_id | ID of the API authorizer resource, applies to all endpoints in the module | N | null |
| tags | The map of tags to apply to taggable resources | N | empty map |
| provider_lambda_settings | Configuration settings for the Lambda function used by the provider-level routes | N | empty map |
| version_lambda_settings | Configuration settings for the Lambda function used by the version-level routes | N | empty map |

### provider_lambda_settings and version_lambda_settings Variable Default Values

| Name | Description | Value |
|------|-------------|-------|
| timeout | The function execution timeout, in seconds| 3 |
| memory | The function memory setting, in MiB | 128 |
| runtime | The function runtime | python3.8 |
| handler | The function handler name | wkt.lambda_handler |

## Output Variables

The provider-level and version-level routes are exposed as distinct filtered map of properties for their respective
API Gateway route resource.  Exposed map keys in each map are:
  * id
  * arn
  * name
  * api_id
  * route_key