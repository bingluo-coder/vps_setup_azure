#!/bin/bash
tokenFile=$1
ip=$2

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
[ ! -f "$tokenFile" ] && echo "ERROR: provide a valid token file as parameter"&&exit 1
token=`cat $tokenFile`
fqdn=`basename ${tokenFile} '.token'`
echo -n `date +"[%m-%d %H:%M:%S]"`$'\t' | tee -a ddns.log
if [ -z "${ip}" ]; then
       	curl -s "https://anondns.net/api/set/${fqdn}/${token}/a/`curl -s ifconfig.me`" | tee -a  ddns.log && echo ''|tee -a ddns.log
else
	curl -s "https://anondns.net/api/set/${fqdn}/${token}/a/${ip}" | tee -a  ddns.log && echo ''|tee -a ddns.log
fi
