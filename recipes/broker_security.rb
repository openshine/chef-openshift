#
# Cookbook Name:: openshift
# Recipe:: broker_security
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
OPENSHIFT_BROKER_HOSTNAME = node["openshift"]["broker"]["hostname"]

service "sshd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

openshift_fwd "Enable ssh firewall" do
  type "service"
  service "ssh"
  action :add
end

openshift_fwd "Enable http firewall" do
  type "service"
  service "http"
  action :add
end

openshift_fwd "Enable https firewall" do
  type "service"
  service "https"
  action :add
end

#Ssl certs
execute "generate ssl private key" do
   cwd "/etc/openshift"
   user "root"
   command "openssl genrsa -out /etc/openshift/server_priv.pem 2048"
   not_if { ::File.exists?("/etc/openshift/server_priv.pem") }
end

execute "generate ssl public key" do
   cwd "/etc/openshift"
   user "root"
   command "openssl rsa -in /etc/openshift/server_priv.pem -pubout > /etc/openshift/server_pub.pem"
   not_if { ::File.exists?("/etc/openshift/server_pub.pem") }
end

execute "generate rsync ssh keys" do
  cwd "/etc/openshift"
  user "root"
  command "ssh-keygen -q -t rsa -b 2048 -f /root/.ssh/rsync_id_rsa -N '' -C 'openshift@#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}'"
  not_if { ::File.exists?("/root/.ssh/rsync_id_rsa") }
end

execute "copy rsync ssh keys to /etc/openshift/" do
  cwd "/etc/openshift"
  user "root"
  command "cp /root/.ssh/rsync_id_rsa* ."
  not_if { ::File.exists?("/etc/openshift/rsync_id_rsa") }
end

execute "copy rsync public ssh keys to openshift sync user" do
  cwd "#{node["openshift"]["sync"]["home"]}"
  user "root"
  command "cp /root/.ssh/rsync_id_rsa.pub ."
  only_if { node["openshift"]["sync"]["enable"] }
end

#Selinux settings
execute "set selinux policies" do
  cwd "/etc/openshift"
  user "root"
  command "setsebool -P httpd_unified=on httpd_can_network_connect=on httpd_can_network_relay=on httpd_run_stickshift=on named_write_master_zones=on"
end

%w{rubygem-passenger mod_passenger}.each do |pkg|
  execute "Selinux fixfiles for package #{pkg}" do
    cwd "/etc/openshift"
    user "root"
    command "fixfiles -R #{pkg} restore"
  end
end

execute "restorecon -rv /var/run"
execute "restorecon -rv /usr/share/gems/gems/passenger-*"
