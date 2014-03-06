#
# Cookbook Name:: openshift
# Recipe:: broker_sync
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
OPENSHIFT_BROKER_IP = node["openshift"]["broker"]["ipaddress"] == "" ? node["ipaddress"] : node["openshift"]["broker"]["ipaddress"]
OPENSHIFT_BROKER_HOSTNAME = node["openshift"]["broker"]["hostname"]

if node["openshift"]["avahi"]["enable"]
  package "avahi"
  package "nss-mdns"

  template "/etc/avahi/avahi-daemon.conf" do
    source "avahi/avahi-daemon.conf.erb"
    mode 0644
    owner "root"
    group "root"
    variables(:hostname => OPENSHIFT_BROKER_HOSTNAME,
              :domain => "#{OPENSHIFT_DOMAIN}.local")
  end

  template "/etc/avahi/cname-manager.conf" do
    source "avahi/cname-manager.conf.erb"
    mode 0644
    owner "root"
    group "root"
    variables(:hostname => OPENSHIFT_BROKER_HOSTNAME,
              :domain => "#{OPENSHIFT_DOMAIN}.local")
  end

  service "avahi-daemon" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :restart ]
  end
end
