# ecxy
## require
- jq
- aws cli
- aws session manager plugin

## description
ECS execを対話形式でできるようにするためのツール

クラスタ、タスク、コンテナを1つ1つ調べる必要がなく簡単にできるようにと
`ECS exec made easy`から ecxy（エクシー） と命名した。


## option
- `-p [your profile]` : プロファイルを指定
- `-a` : /bin/ash でコンテナに入る（デフォルトは/bin/bash）
