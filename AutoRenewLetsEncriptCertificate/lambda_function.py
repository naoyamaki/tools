from boto3.session import Session
import os
import json
import datetime
import pytz
import socket
import ssl
import requests
import sys

jst = pytz.timezone('Asia/Tokyo')

SLACK_HOOK_URL = os.environ['SLACK_HOOK_URL']
OPEN_SECURITY_GROUP = os.environ['OPEN_SECURITY_GROUP']
SITES_ENV = [
  {
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example1.com',
    "web_root" : "/var/www/html/",
    "hook" : "systemctl reload httpd"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example2.com',
    "web_root" : "/var/www/html/",
    "hook" : "service httpd reload"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example3.com',
    "web_root" : "/var/www/html/",
    "hook" : "systemctl reload httpd"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example4.com',
    "web_root" : "/var/www/html/",
    "hook" : "service httpd reload"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example5.com',
    "web_root" : "/var/www/html/",
    "hook" : "systemctl reload httpd"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example6.com',
    "web_root" : "/var/www/html/",
    "hook" : "service httpd reload"
  },{
    "instance_id" : "i-xxxxxxxxxxx",
    "host" : 'example7.com',
    "web_root" : "/var/www/html/",
    "hook" : "systemctl reload httpd"
  }
]

ec2_client = boto3.client('ec2', 'ap-northeast-1')
ssm_client = boto3.client('ssm')

def count_days_from_deadline(host):
  return 20

def lambda_handler(event, context):
  for site_env in SITES_ENV:

    # 現状のSGを取得
    response = ec2_client.describe_instance_attribute(
      Attribute = 'groupSet',
      InstanceId = site_env["instance_id"]
    )

    # 用意してあるセキュリティグループを追加
    ec2_client.modify_instance_attribute(
      InstanceId = site_env["instance_id"],
      Groups = [response['Groups'], OPEN_SECURITY_GROUP]
    )

    # 証明書期限が30日以上であれば、次のサイトのループへ
    if count_days_from_deadline(site_env["host"]) > 30:
      continue

    # 証明書更新処理実行
    response = ssm.send_command(
      InstanceIds = [site_env["instance_id"]],
      DocumentName = "AWS-RunShellScript",
      Parameters = {
        "commands": [
#          shellファイルを用意しないでやる方法
#          "/bin/certbot-auto renew --webroot-path "+WEB_ROOT+" --post-hook '"+CERT_BOT_HOOK+"' --preferred-chain 'DST Root CA X3'"
          "sudo sh /root/cert_renew.sh"
        ],
        "executionTimeout": ["60"]
      },
    )

    renew_period = count_days_from_deadline(site_env["host"])
    message = "証明書の期限はあと"+renew_period+"日です"
    # 証明書更新完了通知
    requests.post(SLACK_HOOK_URL, data=json.dumps({"text" : message,}))

