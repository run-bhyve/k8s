#!/bin/bash

[[ "TRACE" ]] && set -x

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}

source $INSTALL_PATH/../config

[ ! -d $CERTIFICATE/certs ] && mkdir -p $CERTIFICATE/certs
pushd $CERTIFICATE/certs

[ -r server-openssl.cnf ] && rm -f server-openssl.cnf

for i in server.key server.csr server.crt; do
	[ -r ${i} ] && rm -f ${i}
done

popd
