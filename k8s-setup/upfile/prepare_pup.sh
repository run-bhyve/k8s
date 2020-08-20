#!/bin/sh
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin"

if [ "${1}" = "gold" ]; then
	# in gold
	wget -O /tmp/puppet.deb https://apt.puppet.com/puppet6-release-$( lsb_release -sc ).deb
	dpkg -i  /tmp/puppet.deb
	apt update -y
	apt install -y puppet-agent
	systemctl stop puppet.service >/dev/null 2>&1 || true
	systemctl disable puppet.service >/dev/null 2>&1 || true
	cd /home/ubuntu
	tar xfz puppet.tgz
	rm -f puppet.tgz
	rm -rf /etc/puppetlabs/puppet
	mv puppet /etc/puppetlabs
	rm -rf /etc/puppetlabs/code/environments/production/modules || true
	[ ! -d /etc/puppetlabs/code/environments/production ] && mkdir -p /etc/puppetlabs/code/environments/production
	ln -sf /etc/puppetlabs/puppet/modules /etc/puppetlabs/code/environments/production/modules
else
	tar xfz puppet.tgz
	rm -f puppet.tgz
	rm -rf /etc/puppetlabs/puppet
	mv puppet /etc/puppetlabs
	rm -rf /etc/puppetlabs/code/environments/production/modules || true
	[ ! -d /etc/puppetlabs/code/environments/production ] && mkdir -p /etc/puppetlabs/code/environments/production
	ln -sf /etc/puppetlabs/puppet/modules /etc/puppetlabs/code/environments/production/modules

	cd /opt/puppetlabs/puppet
	puppet apply /etc/puppetlabs/puppet/site.pp
	puppet apply /etc/puppetlabs/puppet/site.pp
fi

exit 0
