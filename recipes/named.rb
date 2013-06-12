#
# Cookbook Name:: openshift
# Recipe:: named
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
FW_ADD_SERVICE_CMD = node["openshift"]["firewall"]["add_service"]

package "bind"
package "bind-utils"

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

file "/etc/rndc.key" do
  owner "root"
  group "named"
  mode "640"
end

template "/var/named/forwarders.conf" do
  source "named_forwarders.conf.erb"
  mode 0755
  owner "named"
  group "named"
  variables({ :ip_list => node["openshift"]["named"]["forwarders"] })
end

template "/var/named/dynamic/#{OPENSHIFT_DOMAIN}.db" do
  source "named_dynamic-domain.db.erb"
  mode 0755
  owner "named"
  group "named"
  variables({ :domain => "#{OPENSHIFT_DOMAIN}" })
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
    res.source "named_domain-key.erb"
    res.owner "named"
    res.group "named"
    res.mode "750"
    res.cookbook "openshift"
    res.variables({ :domain => "#{OPENSHIFT_DOMAIN}",
                    :key => "#{dns_key}"
                  })
    res.run_action :create
  end
end

template "/etc/named.conf" do
  source "named_named.conf.erb"
  mode 0755
  owner "root"
  group "named"
  variables({ :domain => "#{OPENSHIFT_DOMAIN}" })
end

execute "Enable dns firewall" do
  cwd "/var/named"
  command "#{FW_ADD_SERVICE_CMD}dns"
end

service "named" do
 supports :status => true, :restart => true, :reload => true
 action [ :enable, :start ]
end

bash "nsupdate" do
  cwd "/var/named"
  user "root"
  code <<-EOH
     KEYFILE=/var/named/${DOMAIN}.key
     B="/var/named/batch.txt"
     echo "server 127.0.0.1" > ${B}
     echo "update delete broker.${DOMAIN} A" >> ${B}
     echo "update add broker.${DOMAIN} 180 A ${IP}" >> ${B}
     echo "send" >> ${B}
     nsupdate -k ${KEYFILE} ${B}
     rm ${B}
  EOH
  environment({ 'DOMAIN' => "#{OPENSHIFT_DOMAIN}", 'IP' => node["ipaddress"]})
end
