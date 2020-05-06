Implement using HTTP API Gateway
 - authentication from `terraform login` is Oauth2 only
   - See https://www.terraform.io/docs/commands/login.html for details
   - The idea of using IAM for registry auth fails since there's no way for TF to send a signed AWS request to the API
   - How can we make the Oauth2 integration "nice"? (avoid unique credentials, credential caching, etc)
   - will need to implement TF login protocol support (https://www.terraform.io/docs/internals/login-protocol.html)
   - how to handle credentials for things like CI tools (this is probably more of an Oauth2 provider issue)
 - $default stage name allows us to avoid dealing with the silliness of the REST API stages and custom domain mappings

 GET   <base_url>                                                application/json - List all modules in registry, allows 'provider' query string param to only return specified provider
 GET   <base_url>/search                                         application/json - Search for module (implementation-specific), explicitly supports namespace, provider, and verified query string opts
 GET   <base_url>/:namespace                                     application/json - List all modules under :namespace, allows 'provider' query string param to only return specified provider
 GET   <base_url>/:namespace/:name                               application/json - List latest module version for all providers, does _not_ explicitly specify 'provider' query string param
xGET   <base_url>/:namespace/:name/:provider                     application/json - List latest module version for specific :provider

xGETx  <base_url>/:namespace/:name/:provider/versions            application/json - List all module versions for :provider
 - https://www.terraform.io/docs/registry/api.html#list-available-versions-for-a-specific-module
 - See Also https://github.com/hashicorp/terraform/blob/master/registry/response/module_versions.go for structure of response

xGETx  <base_url>/:namespace/:name/:provider/download            application/json - Download latest module version
 - HTTP 302 redirect which points to version-specific download URL for the latest version
 - https://www.terraform.io/docs/registry/api.html#download-the-latest-version-of-a-module

xGET   <base_url>/:namespace/:name/:provider/:version            application/json - Show info for specified version of the module

xGETx  <base_url>/:namespace/:name/:provider/:version/download   application/json - Download specific module version
 - HTTP 204 (or 200?) with no response body and X-Terraform-Get header with URL to download module code
 - https://www.terraform.io/docs/registry/api.html#download-source-code-for-a-specific-module-version


GETx paths seem to be the only required setup for terraform to pull a module from the repo, the rest are probably helpful for
UI nav and display of module info

support proxying request to public registry if requests under /:namespace fail (not found) local lookup?
 - why?  If you just remove that 'host' portion of the module source, you search the "official" registry by default


High-level returned data elements (there are other module-specific things like input/output vars, submodules, etc for some methods):

{
  "id": "terraform-aws-modules/vpc/aws/1.5.1", # namespace + name + provider + version
  "owner": "",
  "namespace": "terraform-aws-modules",
  "name": "vpc",
  "version": "1.5.1",
  "provider": "aws",
  "description": "Terraform module which creates VPC resources on AWS",
  "source": "https://github.com/terraform-aws-modules/terraform-aws-vpc",
  "published_at": "2017-11-23T10:48:09.400166Z",
  "downloads": 29714,
  "verified": true
  "checksum": "checksum of the file as it is stored"
}
    
    
DDB Model
Partition/HASH Key = namespace/name
Sort/RANGE Key = provider/version - contains at least the attributes below
                 provider/latest - only attribute is version, used as a pointer back to the actual entry (use an is_null filter on something like the description or downloads attribute to make the search easy)

"common" attributes
name - in case we want to create a GSI with this as one of the keys, otherwise project as an attribute
provider - for GSI projection
version - for GSI projection
description - for GSI projection
verified - for possible GSI projection
published_at - for possible GSI projection
owner - for possible GSI projection
source - source repo url
downloads - counter to track module downloads
download_url - stored URL for X-Terraform-Get, or should we compose this based on a known location (S3?) and these attributes instead?

GSI Partition Key = namespace  # eventual support for /, /:namespace, and /search
GSI Sort Key = name (?)
GSI Projected attributes = provider, version, description, name (if not used for Sort key), verified, published_at (?), owner (?)