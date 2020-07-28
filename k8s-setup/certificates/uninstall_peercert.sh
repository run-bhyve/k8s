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
 -f|--file)
 FILENAME="$2"
 shift
 shift
 ;;
 -t|--type)
 TYPE="$2"
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
if [ -z "$FILENAME" ]
then
	echo "Please provide node filename"
	exit 0
fi
if [ -z "$TYPE" ]
then
	echo "Please provide file type"
	exit 0
fi

: ${CA_COUNTRY:=IN}
: ${CA_STATE:=UP}
: ${CA_LOCALITY:=GN}
: ${CA_ORGANIZATION:=CloudInc}
: ${CA_ORGU:=IT}
: ${CA_EMAIL:=cloudinc.gmail.com}
: ${CA_COMMONNAME:=kube-system}

[ ! -d $CERTIFICATE/certs ] && mkdir -p $CERTIFICATE/certs
pushd $CERTIFICATE/certs

if [ $TYPE == 'server' ]
then
	keyUsage='extendedKeyUsage = clientAuth,serverAuth'
	HOSTNAME="${HOSTNAME}-${FILENAME}"
else
	keyUsage='extendedKeyUsage = clientAuth'
	FILENAME="${FILENAME}-client"
	HOSTNAME="${HOSTNAME}-$FILENAME"
fi

[ -r ${FILENAME}-openssl.cnf ] && rm -f ${FILENAME}-openssl.cnf

for i in ${HOSTNAME}.key ${HOSTNAME}.csr ${HOSTNAME}.crt; do
	[ -r ${i} ] && rm -f ${i}
done

popd
