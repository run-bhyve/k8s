

https://github.com/sumitmaji/kubernetes.git

dd if=/dev/urandom of=/home/ubuntu/.rnd bs=256 count=1
/kubernetes/certificates/install_peercert.sh -i 10.10.10.2 -h master.cloud.com -t client -f etcd

install_scripts/install_kubeconfig.sh
#echo "admin,admin,admin" > /export/kubecertificate/certs/basic_auth.csv


# STEPS (in CBSDFile)
#/export/kubernetes/certificates/install_ca.sh
#/export/kubernetes/certificates/install_certificates.sh
#/kubernetes/certificates/install_peercert.sh -i 10.0.0.2 -h master.cloud.com -t client -f etcd

/export/kubernetes/install_scripts_secure/install_master.sh





# NEW
apt update -y
apt install -y docker.io
/kubernetes/install_scripts/install_haproxy.sh
/export/kubernetes/certificates/install_ca.sh
/export/kubernetes/certificates/install_certificates.sh
/export/kubernetes/install_scripts_secure/install_master.sh

#/export/kubernetes/install_scripts_secure/install_ingress.sh

curl --cacert /export/kubecertificate/certs/ca.crt https://master.cloud.com/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
https://computingforgeeks.com/join-new-kubernetes-worker-node-to-existing-cluster/

