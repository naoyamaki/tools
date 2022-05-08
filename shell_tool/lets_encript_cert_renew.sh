#!/bin/bash

readonly DOMAIN_NAME='example.com'
readonly WEB_ROOT='/var/www/html/'
#readonly CERT_BOT_HOOK='service httpd reload'
readonly CERT_BOT_HOOK='systemctl reload httpd'
readonly FULLCHAINPATH="/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem"
readonly MON_PAR_SEC=2592000
readonly HOOK_URL='https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/xxxxxxxxxxxxxx'
cert_end_date=`openssl x509 -noout -text -in ${FULLCHAINPATH} | grep -oP '(?<=Not After : ).+(?= GMT)'`
cert_end_date_sec=`date -d "${cert_end_date}" +%s`
now_sec=`date +%s`

if [ `expr $cert_end_date_sec - $now_sec` -lt $MON_PAR_SEC ] ; then
  /bin/certbot-auto renew --webroot-path ${WEB_ROOT} --post-hook "${CERT_BOT_HOOK}" --preferred-chain "DST Root CA X3"
  renew_cert_date=`openssl x509 -noout -text -in ${FULLCHAINPATH} | grep -oP '(?<=Not After : ).+(?= GMT)'`
  renew_cert_date=`date -d "${renew_cert_date}" '+%Y/%m/%d'`
  curl -X POST --data-urlencode "payload={\"text\": \"<!subteam^S02KV164SQ1> ${DOMAIN_NAME}の証明書期限は${renew_cert_date}です。\"}" ${HOOK_URL}
fi