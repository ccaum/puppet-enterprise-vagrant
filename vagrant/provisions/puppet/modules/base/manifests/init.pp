class base {

  service { 'pe-httpd':
    ensure => running,
    enable => true,
  }

  file { '/root/.bashrc':
    ensure => symlink,
    target => '/vagrant/shared/pe-master/root.bashrc',
    force  => true,
  }

  host { 'puppet':
    host_aliases => 'master.vagrant.internal',
    ip           => '33.33.33.10',
  }

  host { 'agent1.vagrant.internal':
    ip => '33.33.33.11',
  }

  host { 'agent2.vagrant.internal':
    ip => '33.33.33.12',
  }

}
