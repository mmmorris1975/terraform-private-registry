# Private Terraform Registry for AWS

This module build a private Terraform module registry using an HTTP AWS API Gateway for the API implementation
(optionally secured by an Oauth2 API authorizer), using DynamoDB as the datastore for the module metadata.  The module
also includes all of the necessary Lambda function code to implement the necessary logic for the terraform command to
interact with the registry.

For now, this module should be considered EXPERIMENTAL. The HTTP API Gateway support in Terraform is still very new,
and there are some known issues which require resolution in the AWS provider before this can be considered fully usable.

The module does not ship with a UI, or provide support for uploading and indexing new modules to the registry. It
currently only provides enough support for the terraform command to successfully download a module from the registry.

## Example

### Default, unauthenticated registry
```hcl-terraform
module "registry" {
  source = "path/to/terraform-registry"
}
```

### Oauth2 authenticated registry
```hcl-terraform
module "registry" {
  source = "path/to/terraform-registry"

  auth_config = {
    issuer    = "MyOauth2IssuerUrl"
    audience  = ["MyOauth2Audience"]
    client_id = "MyOauth2ClientId"
    ports     = [12340, 12349]

    authz_endpoint = "https://oauth2.example.com/oauth2/authorization"
    token_endpoint = "https://oauth2.example.com/oauth2/token"
  }
}
```

## Input Variables

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| auth_config | Optional JWT Authorizer configuration for the API | N | null |
| api_config | A map of configuration for the API resources | N | empty map |
| tags | The map of tags to apply to taggable resources | N | empty map |

### api_config Variable Default Values

| Name | Description | Value |
|------|-------------|-------|
| name | The name used for the registry. Will be used as part of the name for all resources managed by this module. | terraform-registry |
| modules_v1_path | The base path used for the registry modules.v1 API | /v1/modules |

## Output Variables

A filtered set of the attributes for the API Gateway, API Authorizer, Lambda IAM Role, DynamoDB Datasource,
Discovery and Modules API are exposed as output variables from this module.  At a minimum, the attributes exposed are:
  * id
  * arn
  * name
