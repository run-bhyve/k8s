#!/bin/bash

apt update -y
apt install -y docker.io
systemctl enable docker.service
/kubernetes/install_scripts/install_binaries.sh

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts_secure}

source $INSTALL_PATH/../config
if [ $ENABLE_DEBUG == 'true' ]
then
 [[ "TRACE" ]] && set -x
fi

if [ -r $INSTALL_PATH/install_kubelet-${K8S_VER}.sh ]; then
	echo "kubelet for ${K8S_VER}"
	/bin/bash $INSTALL_PATH/install_kubelet-${K8S_VER}.sh
	ret=$?
else
	echo "kubelet for ${K8S_VER}"
	/bin/bash $INSTALL_PATH/install_kubelet.sh
	ret=$?
fi



/bin/bash $INSTALL_PATH/install_kube_proxy.sh
/bin/bash $INSTALL_PATH/install_flannel.sh
