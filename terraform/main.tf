terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
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

# 関数名をディレクトリ名と一致させて管理
locals {
  # 変数名は仮
  function_name = "runcommandsanple"
  function_dir = "lambda/runcommandsanple"
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = local.function_dir
  output_path = "archive/${local.function_name}.zip"
}

# レイヤー未作成なのでエラーになるlambdaをデプロイしている
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  handler       = "lambda.handler"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"


  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256

  environment {
    variables = {
      HOOK_URL = "https://hogehoge.com/service/hogehoge/fugafuga/"
    }
  }
}