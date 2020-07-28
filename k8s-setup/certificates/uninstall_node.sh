#!/bin/bash

[[ "TRACE" ]] && set -x

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}
#NODE_IP=$2
source $INSTALL_PATH/../config
#HOSTNAME=$1

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
 -i|--ip)
 NODE_IP="$2"
 shift
 shift
 ;;
 -h|--host)
 HOSTNAME="$2"
 shift
 shift
 ;;
esac
done

if [ -z "$NODE_IP" ]
then
	echo "Please provide node ip"
	exit 0
fi
if [ -z "$HOSTNAME" ]
then
	echo "Please provide node hostname"
	exit 0
fi

[ ! -d $CERTIFICATE/certs ] && mkdir -p $CERTIFICATE/certs
pushd $CERTIFICATE/certs

[ -r node-openssl.cnf ] && rm -f node-openssl.cnf

for i in ${HOSTNAME}.key ${HOSTNAME}.csr ${HOSTNAME}.crt; do
	[ -r ${i} ] && rm -f ${i}
done

popd
