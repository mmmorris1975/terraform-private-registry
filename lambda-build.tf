locals {
  build_id = uuid()
}

# Force a build/package of the zip file every time we run an apply
resource "null_resource" "build" {
  triggers = {
    id = local.build_id
  }

  provisioner "local-exec" {
    command = "rm -f lambda.*.zip && cd code && zip -r ../lambda.${local.build_id}.zip * */**"
  }
}