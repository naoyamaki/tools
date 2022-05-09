terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.13.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  backend "s3" {
    bucket = "anax-parthenope"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# py_slack_notice関数
## zip作成
data "archive_file" "layer_requests" {
  type        = "zip"
  source_dir  = "lambda-src/layers/requests"
  output_path = "lambda-src/layer-archives/requests.zip"
}
data "archive_file" "function_py_slack_notice" {
  type        = "zip"
  source_dir  = "lambda-src/functions/py_slack_notice"
  output_path = "lambda-src/function-archives/py_slack_notice.zip"
}
## 関数の設定
resource "aws_lambda_function" "py_slack_notice" {
  function_name = "py_slack_notice"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  layers = ["${aws_lambda_layer_version.py_slack_notice.arn}"]
  filename         = data.archive_file.function_py_slack_notice.output_path
  source_code_hash = data.archive_file.function_py_slack_notice.output_base64sha256

  environment {
    variables = {
      HOOK_URL = "https://hooks.slack.com/services/XXXXXXXXXX/XXXXXXXXXX/XXXXXXXXXX"
    }
  }
}
### 関数とlayerを紐付け
resource "aws_lambda_layer_version" "py_slack_notice" {
  layer_name       = "requests"
  filename         = data.archive_file.layer_requests.output_path
  source_code_hash = data.archive_file.layer_requests.output_base64sha256
}
### 関数にエンドポイント付与
resource "aws_lambda_function_url" "py_slack_notice" {
  function_name      = aws_lambda_function.py_slack_notice.arn
  authorization_type = "AWS_IAM"
}

# js_slack_notice関数
data "archive_file" "function_js_slack_notice" {
  type        = "zip"
  source_dir  = "lambda-src/functions/js_slack_notice"
  output_path = "lambda-src/function-archives/js_slack_notice.zip"
}
resource "aws_lambda_function" "js_slack_notice" {
  function_name = "js_slack_notice"
  handler       = "index.handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "nodejs14.x"
  filename         = data.archive_file.function_js_slack_notice.output_path
  source_code_hash = data.archive_file.function_js_slack_notice.output_base64sha256

  environment {
    variables = {
      HOOK_URL = "https://hooks.slack.com/services/XXXXXXXXXX/XXXXXXXXXX/XXXXXXXXXX"
    }
  }
}