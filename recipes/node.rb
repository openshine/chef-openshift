#
# Cookbook Name:: openshift
# Recipe:: node
#
# Copyright 2013, Openshine S.L.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

OPENSHIFT_DOMAIN = node["openshift"]["domain"]
OPENSHIFT_NODE_IP = node["openshift"]["node"]["ipaddress"] == "" ? node["ipaddress"] : node["openshift"]["node"]["ipaddress"]
OPENSHIFT_NODE_HOSTNAME = node["openshift"]["node"]["hostname"]
OPENSHIFT_BROKER_IP = node["openshift"]["broker"]["ipaddress"] == "" ? node["ipaddress"] : node["openshift"]["broker"]["ipaddress"]
OPENSHIFT_BROKER_HOSTNAME = node["openshift"]["broker"]["hostname"]

hostsfile_entry OPENSHIFT_BROKER_IP do
  hostname "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
  comment "openshift broker"
  action    :append
end

hostsfile_entry OPENSHIFT_NODE_IP do
  hostname "#{OPENSHIFT_NODE_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
  comment "openshift node"
  action    :append
end

include_recipe "openshift::nightly"
include_recipe "openshift::node_dhcp"
include_recipe "openshift::node_sync"
include_recipe "openshift::node_messaging"

%w{rubygem-openshift-origin-node
   rubygem-passenger-native
   openshift-origin-port-proxy
   openshift-origin-node-util
   openshift-origin-cartridge-cron-1.4
   openshift-origin-cartridge-diy-0.1
}.each do |pkg|
  package pkg
end

include_recipe "openshift::node_security"
include_recipe "openshift::node_cgroups"
include_recipe "openshift::node_quota"
include_recipe "openshift::node_sysctl"

openshift_fwd "Enable proxy port firewall" do
  type "portrange"
  portrange "35531-65535"
  protocol "tcp"
  action :add
end

service "openshift-port-proxy" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :restart ]
end

template "/etc/openshift/node.conf" do
  source "node/node.conf.erb"
  mode 0644
  owner "root"
  group "root"
  variables({ :domain => OPENSHIFT_DOMAIN,
              :broker_ip => OPENSHIFT_BROKER_IP,
              :node_ip => OPENSHIFT_NODE_IP,
              :node_fqdn => "#{OPENSHIFT_NODE_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
            })
end

execute "/etc/cron.minutely/openshift-facts"

service "openshift-gears" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :restart ]
end
