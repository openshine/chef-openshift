#
# Cookbook Name:: openshift
# Recipe:: broker
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

hostsfile_entry "#{OPENSHIFT_BROKER_IP}" do
  hostname "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
  comment "openshift broker"
  action    :append
end

include_recipe "ntp"
include_recipe "openshift::nightly"
include_recipe "openshift::broker_sync"
include_recipe "openshift::broker_avahi"
include_recipe "openshift::broker_named"
include_recipe "openshift::broker_dhcp"
include_recipe "openshift::broker_mongodb"
include_recipe "openshift::broker_messaging"

%w{openshift-origin-broker
   openshift-origin-broker-util
   rubygem-openshift-origin-auth-remote-user
   rubygem-openshift-origin-msg-broker-mcollective
   rubygem-openshift-origin-dns-bind}.each do |pkg|

  package "#{pkg}"
end

include_recipe "openshift::broker_security"
include_recipe "openshift::broker_config"

if node["platform"] == "fedora" and node["platform_version"] == "18"
  package "libyaml-devel"
  gem_package "psych"
  gem_package "minitest" do
    version "3.2.0"
    action :install
  end
else
  package "rubygem-psych"
end

gem_package "mongoid"
gem_package "mocha"

execute "Bundle broker install" do
  cwd "/var/www/openshift/broker"
  user "root"
  command "bundle --local"
end

service "httpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

service "openshift-broker" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
