# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'berkshelf/vagrant'

Vagrant.configure("2") do |config|
  config.vm.box = "fedora-18-x64-vbox4210"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/fedora-18-x64-vbox4210.box"

  config.berkshelf.enabled = true

  config.vm.provision :shell, :inline => "cd /usr/bin && ln -sf /usr/local/bin/chef-solo ."

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "openshift"

    chef.json = {}
  end
end
