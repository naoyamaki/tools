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

# layerとのディレクトリ分どうしたらいいか考え中
data "archive_file" "layer_source" {
  type        = "zip"
  source_dir  = "lambda/layer/org"
  output_path = "lambda/layer/requests.zip"
}

# 関数名をディレクトリ名と一致させて管理
locals {
  # 変数名は仮
  function_name = "runcommandsanple"
  function_dir  = "lambda/runcommandsanple"
  layer_name    = "requests"
  layer_path    = "lambda/layer"
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = local.function_dir
  output_path = "archive/${local.function_name}.zip"
}

resource "aws_lambda_function" "function" {
  function_name = local.function_name
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  layers = ["${aws_lambda_layer_version.lambda_layer.arn}"]
  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256

  environment {
    variables = {
      HOOK_URL = "https://hooks.slack.com/services/XXXXXXXXXX/XXXXXXXXXX/XXXXXXXXXX"
    }
  }
}

# Layer
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name       = local.layer_name
  filename         = data.archive_file.layer_source.output_path
  source_code_hash = data.archive_file.layer_source.output_base64sha256
}

resource "aws_lambda_function_url" "test_live" {
  function_name      = local.function_name
  authorization_type = "AWS_IAM"
}