cat > /root/.bashrc <<EOF
alias kcd='kubectl config set-context --current --namespace='
EOF
cat > /home/ubuntu/.bashrc <<EOF
alias kcd='kubectl config set-context --current --namespace='
EOF
apt update -y
apt install -y docker.io
SHORT_HOSTNAME=$( hostname -s )
case "${SHORT_HOSTNAME}" in
	master)
		/export/kubernetes/certificates/install_ca.sh
		/export/kubernetes/certificates/install_certificates.sh
		;;
	*)
		max=0
		while [ ${max} -lt 60 ]; do
			if [ ! -r /export/kubecertificate/certs/ca.crt ]; then
				echo "no /export/kubecertificate/certs/ca.crt, waiting ${max}/60..."
				sleep 1
			else
				max=100
			fi
			max=$(( max + 1 ))
		done
		;;
esac
/export/kubernetes/install_scripts_secure/install_master.sh
iptables -t nat -A PREROUTING -p tcp --dport 30000 -j DNAT --to-destination 10.0.0.2:30000 # http
iptables -t nat -A PREROUTING -p tcp --dport 32000 -j DNAT --to-destination 10.0.0.2:32000 # nginx ui
iptables -t nat -A PREROUTING -p tcp --dport 31000 -j DNAT --to-destination 10.0.0.2:31000 # https
