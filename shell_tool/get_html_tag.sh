#!bin/bash

urls=(
'https://example.com/'
'https://example.com/hoge/'
'https://example.com/fuga/'
)

# 必要なタグ
pattern='HTTP/1.1|<title>|name="keywords"|name="description"|property="og:image"|property="og:title"|property="og:description"|property="og:url"|rel="canonical"'

for url in ${urls[@]}; do
	sleep 0.1
	echo '確認URL,'$url >> output.txt
	curl $url | grep -E $pattern >> output.txt
done

# sed -i -e 's/^\<title\>(.*)/titleタグ,$1"/' output.txt
# sed -i -e 's/^\<\/title>\>/"/' output.txt
# sed -i -e 's/^\<meta name="description".*content=/description,/' output.txt
# sed -i -e 's/^\<meta name="keywords".*content=/keywords,/' output.txt
# sed -i -e 's/^\<link rel="canonical".*href=/canonical,/' output.txt
# sed -i -e 's/^\<meta property="og\:title".*content=/og-title,/' output.txt
# sed -i -e 's/^\<meta property="og\:description".*content=/og-description,/' output.txt
# sed -i -e 's/^\<meta property="og\:url".*content=/og-url,/' output.txt
# sed -i -e 's/^\<meta property="og\:image".*content=/og-image,/' output.txt
# sed -i -e 's/ \/>//' output.txt

