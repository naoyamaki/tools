#!/bin/sh

# オプションの処理
sh_command="/bin/bash"
profile=""
while getopts "ap:" opt; do
  case $opt in
    a) sh_command="/bin/ash" ;;
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

# リソース選択関数
select_resource() {
  local resource_name=$1
  shift
  local resources=($@)
  
  if [ ${#resources[@]} -eq 0 ]; then
    echo "${resource_name}が見つかりません" >&2
    return 1
  else
    echo "対象の${resource_name}を選択してください" >&2
  fi
  select resource in "${resources[@]}"; do
    echo "$resource を選択しました" >&2
    echo "$resource"
    break
  done
}

# クラスター選択
clusters=($(aws ecs list-clusters --output json $profile | jq -r '.clusterArns[]'))
if ! cluster=$(select_resource "クラスタ" "${clusters[@]}"); then
  exit 1
fi

# タスク選択
tasks=($(aws ecs list-tasks --cluster $cluster --output json $profile | jq -r '.taskArns[]'))
if ! task=$(select_resource "タスク" "${tasks[@]}"); then
  exit 1
fi

# コンテナ選択
containers=($(aws ecs describe-tasks --cluster $cluster --tasks $task --output json $profile | jq -r '.tasks[].containers[].name'))
if ! container=$(select_resource "コンテナ" "${containers[@]}"); then
  exit 1
fi

aws ecs execute-command --cluster $cluster --task $task --container $container --interactive --command "/bin/bash" $profile
