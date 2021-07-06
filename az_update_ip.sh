#!/bin/bash

APP_ID=$1
PAWD=$2
TENANT_ID=$3
GROUP=$4
VMNAME=$5

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

az login --service-principal -u $APP_ID          --password $PAWD --tenant $TENANT_ID 
nicid=`az vm nic list -g $GROUP --vm-name $VMNAME --query []."id" -o tsv`
nicname=`basename $nicid`
ipconfigName1=`az network nic ip-config list --nic-name $nicname --resource-group $GROUP --query "[?primary].name" -o tsv`
publicIpId=`az network nic ip-config show --name $ipconfigName1  --nic-name $nicname --resource-group $GROUP  --query "publicIpAddress.id" -o tsv`
publicIpName=`basename $publicIpId`

#get secondary ip
ipconfigName2=`az network nic ip-config list --nic-name $nicname --resource-group  $GROUP --query "[?to_string(primary) == 'false'].name" -o tsv`
if [ ! -z "$ipconfigName2" ]; then
	publicIpId2=`az network nic ip-config show --name $ipconfigName2  --nic-name $nicname --resource-group $GROUP  --query "publicIpAddress.id" -o tsv`
	publicIpName2=`basename $publicIpId2`
	ip2=`az network public-ip show -g $GROUP -n $publicIpName2 --query "ipAddress" -o tsv`
	#register backup ip
	bash update_anodns.sh  `ls *.token | head -n 1` $ip2 
fi

#now change ip1

#az network nic ip-config update --name ipconfig1  --nic-name nic236 --resource-group  $GROUP --remove PublicIpAddress
az network nic ip-config update --name $ipconfigName1  --nic-name $nicname --resource-group $GROUP  --remove PublicIpAddress

#az network nic ip-config update --name ipconfig1  --nic-name 236 --resource-group  $GROUP --public-ip-address "ip22"
az network nic ip-config update --name $ipconfigName1  --nic-name $nicname --resource-group $GROUP --public-ip-address $publicIpName

#register primary ip
bash update_anodns.sh  `ls *.token | head -n 1`


#now change ip2
if [ ! -z "$ipconfigName2" ]; then
	#az network nic ip-config update --name ipconfig2  --nic-name nic236 --resource-group  $GROUP --remove PublicIpAddress
	az network nic ip-config update --name $ipconfigName2  --nic-name $nicname --resource-group  $GROUP --remove PublicIpAddress

	#az network nic ip-config update --name ipconfig2  --nic-name nic236 --resource-group  $GROUP --public-ip-address "ip23"
	az network nic ip-config update --name $ipconfigName2  --nic-name $nicname --resource-group $GROUP --public-ip-address $publicIpName2
fi
