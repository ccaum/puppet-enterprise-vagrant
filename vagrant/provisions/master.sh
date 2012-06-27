#!/usr/bin/env bash

# Install Puppet Enterprise as a master.
if ! [ -d /etc/puppetlabs ]; then
  /vagrant/vagrant/provisions/pe/puppet-enterprise-installer -a /vagrant/vagrant/provisions/master.answer
fi

# Auto-sign all agent certificates.
sed -i -e 's/\[master\]/[master]\
    autosign = true/' /etc/puppetlabs/puppet/puppet.conf
