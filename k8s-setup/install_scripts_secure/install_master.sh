#!/bin/bash


: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts_secure}

source $INSTALL_PATH/../config
if [ $ENABLE_DEBUG == 'true' ]
then
	[[ "TRACE" ]] && set -x
fi

/bin/bash $INSTALL_PATH/install_binaries.sh
if [  $? -ne 0 ]
then
	exit 1
fi
/bin/bash $INSTALL_PATH/install_kubeconfig.sh
if [  $? -ne 0 ]
then
	exit 1
fi

if [ -r $INSTALL_PATH/install_etcd-${ETCD_VER}.sh ]; then
	/bin/bash $INSTALL_PATH/install_etcd-${ETCD_VER}.sh
	ret=$?
else
	/bin/bash $INSTALL_PATH/install_etcd.sh
	ret=$?
fi

[ ${ret} -ne 0 ] && exit ${ret}

if $INSTALL_PATH/install_kube_api_server-${K8S_VER}.sh; then
	/bin/bash $INSTALL_PATH/install_kube_api_server-${K8S_VER}.sh
	ret=$?
else
	/bin/bash $INSTALL_PATH/install_kube_api_server.sh
	ret=$?
fi

if [ ${ret} -ne 0 ]
then
	exit 1
fi

/bin/bash $INSTALL_PATH/install_kube_controller_manager.sh
if [  $? -ne 0 ]
then
	exit 1
fi
/bin/bash $INSTALL_PATH/install_kube_scheduler.sh
if [  $? -ne 0 ]
then
	exit 1
fi

if [[ $INSTALL_KUBELET_ON_MASTER == 'true' ]]
then
	/bin/bash $INSTALL_PATH/install_nodes.sh
	if [  $? -ne 0 ]; then
		exit 1
	fi
fi

ln -sf /opt/kubernetes/server/bin/kubectl /usr/bin/kubectl

# install on each master node
/bin/bash $INSTALL_PATH/install_haproxy.sh
if [  $? -ne 0 ]; then
	exit 1
else
	sleep 10
fi

$INSTALL_PATH/install_haproxy.sh

if [ $(hostname -f) == 'master.cloud.com' ]; then
	kubectl create -f $INSTALL_PATH/admin.yaml
	if [ $? -ne 0 ]; then
		echo "kubectl create -f $INSTALL_PATH/admin.yaml"
	fi
else
	# todo - polling for master init success
	sleep 60
fi

if [ $(hostname -f) == 'master.cloud.com' ]; then
	if [[ $INSTALL_DASHBOARD == 'true' ]]
	then
		/bin/bash $INSTALL_PATH/install_dashboard.sh
	fi
else
	sleep 10
fi

$INSTALL_PATH/install_haproxy.sh

if [ $(hostname -f) == 'master.cloud.com' ]; then
	if [[ $INSTALL_SKYDNS == 'true' ]]
	then
		/bin/bash $INSTALL_PATH/install_skydns.sh
	fi
else
	sleep 10
fi

$INSTALL_PATH/install_haproxy.sh

if [[ $INSTALL_INGRESS == 'true' ]]
then
	/bin/bash $INSTALL_PATH/install_ingress.sh
fi

$INSTALL_PATH/install_haproxy.sh


if [[ $INSTALL_HEAPSTER == 'true' ]]
then
	/bin/bash $INSTALL_PATH/install_cadvisor.sh
	/bin/bash $INSTALL_PATH/install_heapster.sh
fi

$INSTALL_PATH/install_haproxy.sh

systemctl restart kubelet.service

# lets sync to master/api:
sleep 10
kubectl label node $( hostname -s ) node-role.kubernetes.io/master=
