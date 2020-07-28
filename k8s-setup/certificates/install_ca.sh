#!/bin/bash

[[ "TRACE" ]] && set -x

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}
source $INSTALL_PATH/../config

: ${CA_COUNTRY:=IN}
: ${CA_STATE:=UP}
: ${CA_LOCALITY:=GN}
: ${CA_ORGANIZATION:=CloudInc}
: ${CA_ORGU:=IT}
: ${CA_EMAIL:=cloudinc.gmail.com}
: ${CA_COMMONNAME:=kube-system}
: ${CA_DAYS:="3650"}


[ ! -d $CERTIFICATE/certs ] && mkdir -p $CERTIFICATE/certs
pushd $CERTIFICATE/certs

if [ -r ca.crt ]; then
	echo "CA already exist"
	exit 0
fi

#Create a self signed certificate
openssl req -new -x509 -nodes -keyout ca.key -out ca.crt -days ${CA_DAYS} -passin pass:sumit \
-subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/OU=${CA_ORGU}/CN=${CA_COMMONNAME}/emailAddress=${CA_EMAIL}"

popd
