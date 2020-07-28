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

[ ! -d $CERTIFICATE/certs ] && mkdir -p $CERTIFICATE/certs
pushd $CERTIFICATE/certs

cat <<EOF | sudo tee server-openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
`
IFS=','
counter=1
for server in $SERVER_DNS; do
echo "DNS.$counter = $server"
counter=$((counter+1))
done
counter=1
for server in $SERVER_IP; do
echo "IP.$counter = $server"
counter=$((counter+1))
done
`
EOF

#Create a private key
if [ ! -r server.key ]; then
	openssl genrsa -out server.key ${CERT_KEY_BIT}
else
	echo "install_certificates: server.key already exist"
fi

#Create CSR for the server
if [ ! -r server.csr ]; then
	#openssl req -new -key server.key -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/OU=${CA_ORGU}/CN=kube-apiserver/emailAddress=${CA_EMAIL}" -out server.csr -config server-openssl.cnf
	#https://medium.com/@oleg.pershin/kubernetes-from-scratch-certificates-53a1a16b5f03
	#openssl req -new -key server.key -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=system:masters/CN=kubernetes-admin/OU=${CA_ORGU}/emailAddress=${CA_EMAIL}" -out server.csr -config server-openssl.cnf
	openssl req -new -nodes -sha256 -key server.key -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/OU=${CA_ORGU}/CN=kube-apiserver/emailAddress=${CA_EMAIL}" -out server.csr -config server-openssl.cnf
else
	echo "install_certificates: server.csr already exist"
fi

#Create a self signed certificate
if [ ! -r server.crt ]; then
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 10000 -extensions v3_req -extfile server-openssl.cnf
	#Verify a Private Key Matches a Certificate
	openssl x509 -noout -text -in server.crt
else
	echo "install_certificates: server.crt already exist"
fi

for user in admin kube-proxy kubelet kube-controller-manager kube-scheduler master.cloud.com; do
	if [ ! -r ${user}.key ]; then
		openssl genrsa -out ${user}.key ${CERT_KEY_BIT}
	else
		echo "install_certificates: ${user}.key already exist"
	fi

	if [ ! -r ${user}.csr ]; then
		#openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}"
		openssl req \
			-new \
			-nodes \
			-sha256 \
			-key ${user}.key \
			-out ${user}.csr \
			-subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=system:masters/CN=kubernetes-admin"
	else
		echo "install_certificates: ${user}.key already exist"
	fi

	if [ ! -r ${user}.crt ]; then
		openssl x509 -req -in ${user}.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${user}.crt -days 7200
	else
		echo "install_certificates: ${user}.crt already exist"
	fi
done

#Install worker nodes
IFS=','
for worker in $WORKERS; do
	oifs=$IFS
	IFS=':'
	read -r ip node <<< "$worker"
	echo "The node $node"
	$INSTALL_PATH/../certificates/install_node.sh -i $ip -h $node
	IFS=$oifs
done
unset IFS

echo "admin,admin,admin" > basic_auth.csv

#Install worker nodes
IFS=','
for worker in $ETCD_CLUSTERS_CERTS; do
	oifs=$IFS
	IFS=':'
	read -r ip node <<< "$worker"
	echo "The node $node"
	$INSTALL_PATH/../certificates/install_peercert.sh -i $ip -h $node -t server -f etcd
	IFS=$oifs
done
unset IFS

#Install worker nodes
IFS=','
for worker in $NODES; do
	oifs=$IFS
	IFS=':'
	read -r ip node <<< "$worker"
	echo "The node $node"
	$INSTALL_PATH/../certificates/install_peercert.sh -i $ip -h $node -t client -f etcd
	IFS=$oifs
done
unset IFS

popd
