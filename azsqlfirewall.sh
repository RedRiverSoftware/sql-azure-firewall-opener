#!/bin/bash

defaultrulename=azsql_$(hostname -s)
rulename=${rulename:-$defaultrulename}

bad=0
if [ -z "$username" ]; then echo "variable 'username' is not set"; bad=1; fi
if [ -z "$password" ]; then echo "variable 'password' is not set"; bad=1; fi
if [ -z "$fqdn" ]; then echo "variable 'fqdn' is not set"; bad=1; fi
if [ $bad -eq 1 ]
then
	echo "please set variables: username, password, fqdn, rulename"
	echo "note: if rulename is not set, azsql_HOSTNAME will be used"
	exit 1
fi

echo getting external IP...
externalip=$(curl -s http://whatismyip.akamai.com/)
echo external IP is $externalip

if [ -z "$tenant" ]; then
	echo logging on to Azure as $username...
	az login -u $username -p $password $extraLoginParams &> /dev/null
else
	echo logging on to Azure as $username for $tenant...
	az login $extra -u $username -p $password -t $tenant $extraLoginParams &> /dev/null
fi
retVal=$?
if [ $retVal -ne 0 ]; then
	echo login failed
	exit 1
else
	echo logged on
fi

if [ -n "$subscription" ]; then
	echo setting subscription $subscription...
	az account set --subscription "$subscription"
	retVal=$?
	if [ $retVal -ne 0 ]; then
		echo set subscription failed
		exit 1
	else
		echo subscription set
	fi
fi

echo getting server list...
servers=$(az sql server list)
retVal=$?
if [ $retVal -ne 0 ]; then
	echo error getting server list
	exit 1
fi

echo looking up $fqdn...
id=$(echo "$servers" | jq -r --arg fqdn $fqdn '.[] | select(.fullyQualifiedDomainName | contains($fqdn)) | .id')
resgrp=$(echo "$servers" | jq -r --arg fqdn $fqdn '.[] | select(.fullyQualifiedDomainName | contains($fqdn)) | .resourceGroup')
srvname=$(echo "$servers" | jq -r --arg fqdn $fqdn '.[] | select(.fullyQualifiedDomainName | contains($fqdn)) | .name')

if [ -z "$id" ]; then
	echo "server not found in list"
	echo "servers:"
	echo $servers
	exit 1
fi

echo "server found, getting existing rules..."
rules=$(az sql server firewall-rule list --id=$id)
retVal=$?
if [ $retVal -ne 0 ]; then
	echo error getting firewall rules
	exit 1
fi

existing=$(echo "$rules" | jq -r --arg externalip $externalip '.[] | select(.startIpAddress | contains($externalip)) | .id')

if [ -n "$existing" ]; then echo "existing rule already covers IP address"; exit 0; fi

namecheck=$(echo "$rules" | jq -r --arg rulename $rulename '.[] | select(.name | contains($rulename)) | .name')

if [ -n "$namecheck" ]
then
	echo "updating existing rule with specified name"
	az sql server firewall-rule update -g=$resgrp -s=$srvname --name=$rulename --start-ip-address=$externalip --end-ip-address=$externalip
else
	echo "creating new rule (no existing rule found with specified name)"
	az sql server firewall-rule create -g=$resgrp -s=$srvname --name=$rulename --start-ip-address=$externalip --end-ip-address=$externalip
fi
