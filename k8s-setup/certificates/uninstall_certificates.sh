#!/bin/bash

[[ "TRACE" ]] && set -x

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts}

source $INSTALL_PATH/../config

if [ -d $CERTIFICATE/certs ]; then
	pushd $CERTIFICATE/certs
	for i in server.key server.csr server.crt; do
		[ -r ${i} ] && rm -f ${i}
	done

	for i in admin kube-proxy kubelet kube-controller-manager kube-scheduler master.cloud.com; do
		[ -r ${i}.key ] && rm -f ${i}.key
		[ -r ${i}.csr ] && rm -f ${i}.csr
		[ -r ${i}.crt ] && rm -f ${i}.crt
	done

	#Uninstall worker nodes
	IFS=','
	for worker in $WORKERS; do
		oifs=$IFS
		IFS=':'
		read -r ip node <<< "$worker"
		echo "The node $node"
		$INSTALL_PATH/../certificates/uninstall_node.sh -i $ip -h $node
		IFS=$oifs
	done
	unset IFS

	[ -r basic_auth.csv ] && rm -f basic_auth.csv

	#Uninstall worker nodes
	IFS=','
	for worker in $ETCD_CLUSTERS_CERTS; do
		oifs=$IFS
		IFS=':'
		read -r ip node <<< "$worker"
		echo "The node $node"
		$INSTALL_PATH/../certificates/uninstall_peercert.sh -i $ip -h $node -t server -f etcd
		IFS=$oifs
	done
	unset IFS

	#Uninstall worker nodes
	IFS=','
	for worker in $NODES; do
		oifs=$IFS
		IFS=':'
		read -r ip node <<< "$worker"
		echo "The node $node"
		$INSTALL_PATH/../certificates/uninstall_peercert.sh -i $ip -h $node -t client -f etcd
		IFS=$oifs
	done
	unset IFS

	popd
fi
