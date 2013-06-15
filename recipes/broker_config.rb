#
# Cookbook Name:: openshift
# Recipe:: broker_config
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

#Tweak /etc/openshift/broker.conf
ruby_block 'Tweak /etc/openshift/broker.conf' do
  block do
    f = Chef::Util::FileEdit.new('etc/openshift/broker.conf')
    f.search_file_replace("^CLOUD_DOMAIN *=.*$", "CLOUD_DOMAIN=\"#{OPENSHIFT_DOMAIN}\"")
    f.search_file_replace("^VALID_GEAR_SIZES *=.*$", "VALID_GEAR_SIZES=\"small,medium\"")
    f.write_file
  end
end

ruby_block 'Add ServerName to /etc/httpd/conf.d/000002_openshift_origin_broker_servername.conf' do
  block do
    f = Chef::Util::FileEdit.new('/etc/httpd/conf.d/000002_openshift_origin_broker_servername.conf')
    f.search_file_replace("ServerName .*$", "ServerName #{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}")
    f.write_file
  end
end

#broker plugins and MongoDB user accounts
execute "openshift-origin-auth-remote-user plugin conf" do
  cwd "/etc/openshift"
  user "root"
  command "cp /usr/share/gems/gems/openshift-origin-auth-remote-user-*/conf/openshift-origin-auth-remote-user.conf.example /etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf"
  not_if { ::File.exists?("/etc/openshift/plugins.d/openshift-origin-auth-remote-user.conf") }
end

execute "openshift-origin-msg-broker-mcollective.conf plugin conf" do
  cwd "/etc/openshift"
  user "root"
  command "cp /etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf.example /etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf"
  not_if { ::File.exists?("/etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf") }
end

ruby_block "create /etc/openshift/plugins.d/openshift-origin-dns-bind.conf template" do
  block do
    dns_key=""
    priv = Dir.glob("/var/named/K#{OPENSHIFT_DOMAIN}*.private")
    File.open(priv[0]).each do |line|
      if line.start_with?("Key:")
        dns_key = line.sub(/^Key: (.*)$/, '\1').strip!
      end
    end

    res = Chef::Resource::Template.new "/etc/openshift/plugins.d/openshift-origin-dns-bind.conf", run_context
    res.source "broker/plugins/dns/bind/dns-bind.conf.erb"
    res.owner "root"
    res.group "root"
    res.mode "644"
    res.cookbook "openshift"
    res.variables({ :domain => "#{OPENSHIFT_DOMAIN}",
                    :ip => "127.0.0.1",
                    :key => "#{dns_key}"
                  })
    res.run_action :create
  end
end

execute "apache openshift-origin-auth-remote-user.conf" do
  cwd "/etc/openshift"
  user "root"
  command "cp -v /var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user-basic.conf.sample /var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user.conf"
  not_if { ::File.exists?("/var/www/openshift/broker/httpd/conf.d/openshift-origin-auth-remote-user.conf") }
end

bash "openshift htpasswd" do
  cwd "/etc/openshift"
  user "root"
  code <<-EOH
    htpasswd -c -b -s /etc/openshift/htpasswd demo demo
  EOH
end

execute "Set mongo user and password" do
  cwd "/etc/openshift"
  user "root"
  command "mongo openshift_broker_dev --eval 'db.addUser(\"openshift\", \"mooo\")'"
end
