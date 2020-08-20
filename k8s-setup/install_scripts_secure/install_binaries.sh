#!/bin/bash

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts_secure}
source $INSTALL_PATH/../config
if [ $ENABLE_DEBUG == 'true' ]
then
 [[ "TRACE" ]] && set -x
fi

[ ! -d ${WORKDIR} ] && mkdir -p $WORKDIR
pushd $WORKDIR
$INSTALL_PATH/setup.sh
pushd workspace/

if [ ! -f kubernetes-server-linux-amd64.tar.gz ]; then
	wget -O kubernetes-server-linux-amd64.tar.gz ${K8S_FETCH_URL}
	ret=$?
	[ ${ret} -ne 0 ] && exit ${ret}
fi

if [ ! -f etcd-linux-amd64.tar.gz ]; then
	wget -O etcd-linux-amd64.tar.gz ${ETCD_FETCH_URL}
	ret=$?
	[ ${ret} -ne 0 ] && exit ${ret}
fi

if [ ! -f flannel-linux-amd64.tar.gz ]; then
	wget -O flannel-linux-amd64.tar.gz ${FLANNEL_FETCH_URL}
	ret=$?
	[ ${ret} -ne 0 ] && exit ${ret}
fi

if [ ! -d /opt/kubernetes ]; then
	tar -xf kubernetes-server-linux-amd64.tar.gz -C /opt/
	[ $? -ne 0 ] && exit 1
fi

for i in ${K8S_BIN_FILES}; do
	if [ ! -r /opt/kubernetes/server/bin/${i} ]; then
		echo "install_binaries: no such /opt/kubernetes/server/bin/${i}"
		exit 1
	fi
	ln -sf /opt/kubernetes/server/bin/${i} /usr/local/bin/${i}
done

#cp /opt/kubernetes/server/bin/{hyperkube,kubeadm,kube-apiserver,kubelet,kube-proxy,kubectl} /usr/local/bin
mkdir -p /var/lib/{kube-controller-manager,kubelet,kube-proxy,kube-scheduler}
mkdir -p /etc/{kubernetes,sysconfig}
mkdir -p /etc/kubernetes/manifests

popd
