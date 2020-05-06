locals {
  lambda_zip_file = "lambda.${uuid()}.zip"
}

# Force a build/package of the zip file every time we run an apply, not the most awesome, but it works
resource "null_resource" "build" {
  triggers = {
    id = local.lambda_zip_file
  }

  # Kind of a neat idea, but since we're always changing the zip file name (so we force a new source_code_hash
  # calculation in the lambda function resources), this actully causes problems since we're sending the "new" name to
  # the lambda functions, but not actually creating it if there's no source code changes
  # triggers = { for e in fileset(path.module, "code/**.py") : e => filebase64sha256(e) }

  provisioner "local-exec" {
    command = "rm -f lambda.*.zip && cd ${path.module}/code && zip -r ../${local.lambda_zip_file} * */**"
  }
}