terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.13.0"
    }
  }
  backend "s3" {
    bucket = "anax-parthenope"
    region = "ap-northeast-1"
    key    = "tool/byStepFunctions/terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_iam_policy" "SFn_policy" {
  name = "LE-cert-auto-renew"
  policy = templatefile("./policy.json", {})
}

resource "aws_iam_role" "SFn_role" {
  name = "LE-cert-auto-renew"
  assume_role_policy = templatefile("./role.json", {})
}

resource "aws_iam_role_policy_attachment" "SFn_role_policy" {
  role       = aws_iam_role.SFn_role.name
  policy_arn = aws_iam_policy.SFn_policy.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name          = "LE-cert-auto-renew"
  definition    = templatefile("./state.json", {})
	role_arn = aws_iam_role.SFn_role.arn
  type          = "STANDARD"
}