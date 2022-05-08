#!bin/bash

output_alarms_file='alarms.json'
output_subscriptions_file='subscriptions.json'

# アラーム一覧を表示しjqで必要な要素のみ抽出
alarms_js=`aws cloudwatch describe-alarms | jq '.MetricAlarms[] | {AlarmName: .AlarmName, AlarmDescription: .AlarmDescription, AlarmActions: .AlarmActions}' > ${output_alarms_file}`

# ARNがSNSのものを抽出し、重複を除外
topics=(`grep -o 'arn:aws:sns:.*[0-9a-zA-Z]' ${output_alarms_file} | awk '!a[$0]++{print}'`)

# トピックの詳細を出力しjqで必要な要素のみ抽出
for topic in ${topics[@]};
do
  aws sns list-subscriptions-by-topic --topic-arn $topic | jq '.Subscriptions[] | {SubscriptionArn: .SubscriptionArn, Protocol: .Protocol, Endpoint: .Endpoint}' >> $output_subscriptions_file
done