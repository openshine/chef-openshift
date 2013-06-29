#
# Cookbook Name:: openshift
# Recipe:: broker_named
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

package "bind"
package "bind-utils"
package "openshift-origin-broker-util"

execute "dnssec-keygen" do
  cwd "/var/named"
  user "root"
  command "dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom #{OPENSHIFT_DOMAIN}"
  not_if { Dir.glob("K*#{OPENSHIFT_DOMAIN}.private").length > 0 }
end

execute "rndc-confgen" do
   cwd "/var/named"
   user "root"
   command "rndc-confgen -a -r /dev/urandom"
   not_if { ::File.exists?("/etc/rndc.key") }
end

execute "restorecon -v /etc/rndc.* /etc/named.*"

file "/etc/rndc.key" do
  owner "root"
  group "named"
  mode "640"
end

template "/var/named/forwarders.conf" do
  source "named/forwarders.conf.erb"
  mode 0755
  owner "named"
  group "named"
  variables({ :ip_list => node["openshift"]["named"]["forwarders"] })
end

execute "restorecon -v /var/named/forwarders.conf"

template "/var/named/dynamic/#{OPENSHIFT_DOMAIN}.db" do
  source "named/dynamic-domain.db.erb"
  mode 0755
  owner "named"
  group "named"
  variables({ :domain => OPENSHIFT_DOMAIN })
end

ruby_block "create /var/named/#{OPENSHIFT_DOMAIN}.key template" do
  block do
    dns_key=""
    priv = Dir.glob("/var/named/K#{OPENSHIFT_DOMAIN}*.private")
    File.open(priv[0]).each do |line|
      if line.start_with?("Key:")
        dns_key = line.sub(/^Key: (.*)$/, '\1').strip!
      end
    end

    res = Chef::Resource::Template.new "/var/named/#{OPENSHIFT_DOMAIN}.key", run_context
    res.source "named/domain-key.erb"
    res.owner "named"
    res.group "named"
    res.mode "750"
    res.cookbook "openshift"
    res.variables({ :domain => OPENSHIFT_DOMAIN,
                    :key => dns_key
                  })
    res.run_action :create
  end
end

execute "restorecon -rv /var/named"

template "/etc/named.conf" do
  source "named/named.conf.erb"
  mode 0755
  owner "root"
  group "named"
  variables({ :domain => OPENSHIFT_DOMAIN })
end

execute "restorecon /etc/named.conf"

openshift_fwd "Enable dns firewall" do
  type "service"
  service "dns"
  action :add
end

service "named" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :start ]
end

execute "nsupdate" do
  cwd "/var/named"
  user "root"
  command "oo-register-dns -s 127.0.0.1 -h #{OPENSHIFT_BROKER_HOSTNAME} -d #{OPENSHIFT_DOMAIN} -n #{OPENSHIFT_BROKER_IP} -k /var/named/#{OPENSHIFT_DOMAIN}.key"
end
