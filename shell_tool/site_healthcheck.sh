#!/bin/bash

HEALTHCHECK_TARGET_URLS=(
  'https://hoge.jp/'
  'https://hoge.hoge.jp/'
  'https://fuga.hoge.jp/'
)

HOOK_URL='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXX/xxxxxxxxxxxxxxxxxxxxxxxx'

date=`date "+%Y/%m/%d %H:%M"`

for url in ${HEALTHCHECK_TARGET_URLS[@]}; do
  status=`curl -LI $url -o /dev/null -w '%{http_code}\n' -s 2>&1`
  if [ $status -ne 200 ]; then
    curl -X POST --data-urlencode "payload={\"text\": \":red_circle: ${url} is unhealthy\"}" $HOOK_URL
  fi
done

curl -X POST --data-urlencode "payload={\"text\": \"${date} end health check\"}" $HOOK_URL