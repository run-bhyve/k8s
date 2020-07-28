#!/bin/bash

[[ "TRACE" ]] && set -x

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}
source $INSTALL_PATH/../config

[ -d $CERTIFICATE/certs ] && rm -rf $CERTIFICATE/certs
