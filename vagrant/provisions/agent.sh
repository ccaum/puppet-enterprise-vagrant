#!/usr/bin/env bash

# Install Puppet Enterprise as an agent.
if ! [ -d /etc/puppetlabs ]; then
  # We only need this during install
  # Puppet provisioning will manage this afterwards
  echo 33.33.33.10 puppet master.vagrant.internal >> /etc/hosts
  echo 33.33.33.11 agent1.vagrant.internal >> /etc/hosts
  echo 33.33.33.12 agent2.vagrant.internal >> /etc/hosts

  /vagrant/vagrant/provisions/pe/puppet-enterprise-installer -a /vagrant/vagrant/provisions/agent.answer

  CONSOLE_PORT=`grep q_puppetmaster_enterpriseconsole_port /vagrant/vagrant/provisions/master.answer | cut -d= -f2`

  # Add this node to the default group.
  VM_OS=`/opt/puppet/bin/facter operatingsystem`
  if [ $VM_OS == Debian ] || [ $VM_OS == Ubuntu ]
    then SERVICE_NAME=pe-puppet-agent
    else SERVICE_NAME=pe-puppet
  fi

  /opt/puppet/bin/puppet resource service $SERVICE_NAME ensure=stopped
  /opt/puppet/bin/puppet agent --test
  /opt/puppet/bin/puppet node classify --enc-ssl --enc-port=$CONSOLE_PORT --enc-auth-user=admin@foo.bar --enc-auth-passwd=console_auth --node-group=default `hostname -f` --enc-server master.vagrant.internal
  /opt/puppet/bin/puppet agent --test
  /opt/puppet/bin/puppet resource service $SERVICE_NAME ensure=running
fi
