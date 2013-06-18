# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'berkshelf/vagrant'

Vagrant.configure("2") do |config|
  config.vm.box = "fedora-19-x64-vbox4210"
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/25363318/fedora-19-x64-vbox4210.box"
  
  config.vm.network :private_network, ip: "34.33.33.10"

  config.berkshelf.enabled = true

  config.vm.provision :shell, :inline => "sed -e 's:enabled=1:enabled=0:g' -i /etc/yum.repos.d/fedora-updates-testing.repo"

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "openshift"

    chef.json = {
      :openshift => {
        :broker => {
          :ipaddress => "34.33.33.10",
          :hostname  => "mybroker"
        },
	:node => {
          :ipaddress => "34.33.33.10",
          :hostname  => "mynode1"
	}
      }
    }
  end
end
