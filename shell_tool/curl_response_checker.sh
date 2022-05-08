#!bin/bash

urls=(
'https://example1.com/'
'https://example2.com/'
'https://example3.com/'
'https://example4.com/'
'https://example5.com/'
)
for url in ${urls[@]}; do
# 適当なwait time
	sleep 0.1
	curl $url -s -o /dev/null -w '%{time_starttransfer}\n'
done

# url_effective      The URL that was fetched last. This is mostly meaningful if you've told curl to follow location: headers.
# http_code          The numerical code that was found in the last retrieved HTTP(S) page.
# time_total         The total time, in seconds, that the full operation lasted. The time will be displayed with millisecond resolution.
# time_namelookup    The time, in seconds, it took from the start until the name resolving was completed.
# time_connect       The time, in seconds, it took from the start until the connect to the remote host (or proxy) was completed.
# time_pretransfer   The time, in seconds, it took from the start until the file transfer is just about to begin. This includes all pre-transfer commands and negotiations that are specific to the particular protocol(s) involved.
# time_starttransfer The time, in seconds, it took from the start until the first byte is just about to be transfered. This includes time_pretransfer and also the time the server needs to calculate the result.
# size_download      The total amount of bytes that were downloaded.
# size_upload        The total amount of bytes that were uploaded.
# size_header        The total amount of bytes of the downloaded headers.
# size_request       The total amount of bytes that were sent in the HTTP request.
# speed_download     The average download speed that curl measured for the complete download.
# speed_upload       The average upload speed that curl measured for the complete upload.
# content_type       The Content-Type of the requested document, if there was any. (Added in 7.9.5)

