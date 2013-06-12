# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'berkshelf/vagrant'

Vagrant.configure("2") do |config|
  config.vm.box = "opscode-centos-6.4-i386"
  config.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_chef-11.4.0.box"

  config.vm.network :private_network, ip: "34.33.33.10"

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "openshift"
  
    chef.json = {}
  end
end
