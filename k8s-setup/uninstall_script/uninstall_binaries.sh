#!/bin/bash

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}
source $INSTALL_PATH/../config
if [ $ENABLE_DEBUG == 'true' ]
then
 [[ "TRACE" ]] && set -x
fi

for i in ${K8S_BIN_FILES}; do
	[ -h /usr/local/bin/${i} -o -f /usr/local/bin/${i} ] && rm -f /usr/local/bin/${i}
done

rm -rf  /var/lib/{kube-controller-manager,kubelet,kube-proxy,kube-scheduler}
rm -rf /etc/kubernetes/manifests
rm -rf /etc/{kubernetes}

for i in etcd-linux-amd64.tar.gz flannel-linux-amd64.tar.gz kubernetes-server-linux-amd64.tar.gz; do
	[ -r ${WORKDIR}/workspace/${i} ] && rm -f ${i}
done

[ -d /opt/kubernetes ] && rm -rf /opt/kubernetes
