require "#{File.dirname(__FILE__)}/vagrant/lib/build"
require "#{File.dirname(__FILE__)}/vagrant/lib/environment"

Vagrant::Config.run do |config|
  config.vm.define :master do |master_config|
    master_config.vm.box = "vanilla-ubuntu-10.04.3-server-i386"
    master_config.vm.box_url = 'http://faro/vagrant/puppetless_boxes/vanilla-ubuntu-10.04.3-server-i386.box'
    master_config.vm.network :hostonly, "33.33.33.10"
    master_config.vm.host_name = "master.vagrant.internal"
    master_config.vm.forward_port 443, 4433
    master_config.vm.provision :shell, :path => "./vagrant/provisions/master.sh"
    master_config.vm.provision :puppet do |puppet|
      puppet.manifest_file = 'site.pp'
      puppet.manifests_path = './vagrant/provisions/puppet/manifests'
      puppet.module_path = './vagrant/provisions/puppet/modules'
    end
  end

  config.vm.define :agent1 do |agent1_config|
    agent1_config.vm.box = "vanilla-ubuntu-10.04.3-server-i386"
    agent1_config.vm.box_url = 'http://faro/vagrant/puppetless_boxes/vanilla-ubuntu-10.04.3-server-i386.box'
    agent1_config.vm.network :hostonly, "33.33.33.11"
    agent1_config.vm.host_name = "agent1.vagrant.internal"
    agent1_config.vm.provision :shell, :path => "./vagrant/provisions/agent.sh"
  end

  config.vm.define :agent2 do |agent2_config|
    agent2_config.vm.box = "vanilla-ubuntu-10.04.3-server-i386"
    agent2_config.vm.box_url = 'http://faro/vagrant/puppetless_boxes/vanilla-ubuntu-10.04.3-server-i386.box'
    agent2_config.vm.network :hostonly, "33.33.33.12"
    agent2_config.vm.host_name = "agent2.vagrant.internal"
    agent2_config.vm.provision :shell, :path => "./vagrant/provisions/agent.sh"
  end
end
