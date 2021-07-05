#!/bin/bash
tokenFile=$1
[ ! -f "$tokenFile" ] && echo "ERROR: provide a valid token file as parameter"&&exit 1
token=`cat $tokenFile`
fqdn=`basename ${tokenFile} '.token'`
echo -n `date +"[%m-%d %H:%M:%S]"`$'\t' | tee -a ddns.log
curl -s "https://anondns.net/api/set/${fqdn}/${token}/a/`curl -s ifconfig.me`" | tee -a  ddns.log && echo ''|tee -a ddns.log
