data "aws_iam_policy_document" "r" {
  statement {
    principals {
      identifiers = [
      "lambda.amazonaws.com"]
      type = "Service"
    }

    actions = [
    "sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name        = format("%s-lambda", aws_apigatewayv2_api.api.name)
  description = format("%s Lambda function execution role", aws_apigatewayv2_api.api.name)
  tags        = var.tags

  assume_role_policy = data.aws_iam_policy_document.r.json
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = [
    aws_dynamodb_table.db.arn]
  }
}

resource "aws_iam_role_policy" "dynamodb" {
  name   = "dynabodb"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.dynamodb.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}