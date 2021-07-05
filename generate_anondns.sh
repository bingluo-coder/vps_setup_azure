#!/bin/bash
host=$1
ip=`curl -s ifconfig.me`
rsp=`curl -s "https://anondns.net/api/register/${host}.anondns.net/a/${ip}"`
code=`echo $rsp | jq -r '.code'`
if [ $code -eq 0 ]; then
	fqdn=`echo $rsp | jq -r '.name'`
	echo $rsp | jq -r '.token' >> ./${fqdn}.token
	echo $fqdn.token
else
	echo $rsp | jq -r '.data'
	exit $code
fi
