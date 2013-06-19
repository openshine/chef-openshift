# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'berkshelf/vagrant'

Vagrant.configure("2") do |config|
  config.vm.define :broker do |broker|
    broker.vm.box = "fedora-19-x64-vbox4210"
    broker.vm.box_url = "https://dl.dropboxusercontent.com/u/25363318/fedora-19-x64-vbox4210.box"
    broker.vm.network :private_network, ip: "34.33.33.10"

    broker.berkshelf.enabled = true

    broker.vm.provision :shell, :inline => "sed -e 's:enabled=1:enabled=0:g' -i /etc/yum.repos.d/fedora-updates-testing.repo"

    broker.vm.provision :chef_solo do |chef|
      chef.add_recipe "openshift::broker"
      chef.json = {
        :openshift => {
          :broker => {
            :ipaddress => "34.33.33.10",
            :hostname  => "mybroker"
          },
          :sync => {
            :enable => true
          }
        }
      }
    end
  end

  config.vm.define :node do |node|
    node.vm.box = "fedora-19-x64-vbox4210"
    node.vm.box_url = "https://dl.dropboxusercontent.com/u/25363318/fedora-19-x64-vbox4210.box"
    node.vm.network :private_network, ip: "34.33.33.11"

    node.berkshelf.enabled = true

    node.vm.provision :shell, :inline => "sed -e 's:enabled=1:enabled=0:g' -i /etc/yum.repos.d/fedora-updates-testing.repo"

    node.vm.provision :chef_solo do |chef|
      chef.add_recipe "openshift::node"
      chef.json = {
        :openshift => {
          :broker => {
            :ipaddress => "34.33.33.10",
            :hostname  => "mybroker"
          },
          :node => {
            :ipaddress => "34.33.33.11",
            :hostname  => "mynode1"
          },
          :sync => {
            :enable => true
          }
        }
      }
    end
  end
end

