#!/bin/sh

# オプションの処理
profile=""
while getopts "p:" opt; do
  case $opt in
    p) profile=$OPTARG ;;
  esac
done

if [ -n "$profile" ]; then
  profile="--profile $profile"
fi

# jq コマンドの確認
if ! command -v jq &> /dev/null; then
  echo "jqコマンドをインストールしてください"
  exit 1
fi

# aws コマンドの確認
if ! command -v aws &> /dev/null; then
  echo "awsコマンドをインストールしてください"
  exit 1
fi

# クラスター選択
clusters=($(aws ecs list-clusters --output json $profile | jq -r '.clusterArns[]'))
if [ ${#clusters[@]} -eq 0 ]; then
  echo "対象のクラスタが見つかりません" >&2
  exit 1
else
  echo "対象のクラスタを選択してください"
fi
select cluster in "${clusters[@]}"; do
  echo $cluster"を選択しました";
  break
done

# タスク選択
tasks=($(aws ecs list-tasks --cluster $cluster --output json $profile | jq -r '.taskArns[]'))
if [ ${#tasks[@]} -eq 0 ]; then
  echo "対象のタスクが見つかりません" >&2
  exit 1
else
  echo "対象のタスクを選択してください"
fi
select task in "${tasks[@]}"; do
  echo $task"を選択しました";
  break
done

# コンテナ選択
containers=($(aws ecs describe-tasks --cluster $cluster --tasks $task --output json $profile | jq -r '.tasks[].containers[].name'))
if [ ${#containers[@]} -eq 0 ]; then
  echo "対象のコンテナが見つかりません" >&2
  exit 1
else
  echo "対象のコンテナを選択してください"
fi
select container in "${containers[@]}"; do
  echo $container"を選択しました";
  break
done

aws ecs execute-command --cluster $cluster --task $task --container $container --interactive --command "/bin/bash" $profile
