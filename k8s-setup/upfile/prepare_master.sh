#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin"

config_swap()
{
	cp -a /etc/fstab /etc/fstab.bak
	swapoff -a
	sed -i  '/swap/d' /etc/fstab
	diff -ruN /etc/fstab.bak /etc/fstab
}

config_swap

cp -a /etc/hosts /etc/hosts-o
egrep -v "master|node" /etc/hosts-o > /etc/hosts
echo '10.0.0.2 node01.cloud.com node01' >> /etc/hosts
echo '10.0.0.3 master2.cloud.com node02.cloud.com master2 node02' >> /etc/hosts
echo '10.0.0.4 master3.cloud.com node03.cloud.com master3 node03' >> /etc/hosts
echo '10.0.0.5 node04.cloud.com node04' >> /etc/hosts
echo '10.0.0.6 node05.cloud.com node05' >> /etc/hosts
echo '10.0.0.100 master.cloud.com master' >> /etc/hosts

SHORT_HOSTNAME=$( hostname -s )

case "${SHORT_HOSTNAME}" in
	master*|node*)
		FQDN="${SHORT_HOSTNAME}.cloud.com"
		;;
	*)
		FQDN="unknown.my.domain"
		;;
esac

echo "${FQDN}" > /etc/hostname
hostname `cat /etc/hostname`

[ -r /root/.ssh/id_ed25519 ] && rm -f /root/.ssh/id_ed25519
[ -r /root/.ssh/authorized_keys ] && rm -f /root/.ssh/authorized_keys

mv /home/ubuntu/id_ed25519 /root/.ssh/
mv /home/ubuntu/authorized_keys /root/.ssh/

chown root:root /root/.ssh/id_ed25519 /root/.ssh/authorized_keys
chmod 0400 /root/.ssh/id_ed25519

rm -rf /kubernetes
mv ~ubuntu/kubernetes.tgz /
cd /
tar xfz kubernetes.tgz

# in gold:
if [ "${1}" = "gold" ]; then
	apt update -y
	apt install -y git net-tools mc
	dd if=/dev/urandom of=/home/ubuntu/.rnd bs=256 count=1
	[ ! -d export ] && mkdir export
	cd export
	ln -sf /kubernetes
fi

cd /kubernetes

exit 0
