import json
import requests
import os

HOOK_URL = os.environ['HOOK_URL']

def lambda_handler(event, context):
    message = "お試しです。"
    requests.post(HOOK_URL, data=json.dumps({"text" : message,}))
