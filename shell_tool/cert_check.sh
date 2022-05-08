#!bin/bash

hosts=(
'hoge1.jp'
'hoge2.jp'
'hoge3.jp'
)


for host in ${hosts[@]}; do
	echo $host'の証明書期限は'
	curl -v https://$host 3> /dev/null 2>&1 1>&3 | grep 'expire date:'
done