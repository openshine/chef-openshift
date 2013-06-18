#
# Cookbook Name:: openshift
# Recipe:: node_sync
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

if ::File.exists?("/var/named/#{OPENSHIFT_DOMAIN}.key") and ::File.exists?("/etc/openshift/rsync_id_rsa")
  package "openshift-origin-broker-util"

  execute "register node with oo-register-dns" do
    command "oo-register-dns -s 127.0.0.1 -h #{OPENSHIFT_NODE_HOSTNAME} -d #{OPENSHIFT_DOMAIN} -n #{OPENSHIFT_NODE_IP} -k /var/named/#{OPENSHIFT_DOMAIN}.key"
  end


  if ::File.exists?("/root/.ssh/authorized_keys")
    ruby_block 'Add /etc/openshift/rsync_id_rsa.pub to /root/.ssh/authorized_keys' do
      block do
        rsa_pub = File.open("/etc/openshift/rsync_id_rsa.pub").read().strip!
        f = Chef::Util::FileEdit.new('/root/.ssh/authorized_keys')
        f.insert_line_if_no_match(rsa_pub, rsa_pub)
        f.write_file
      end
    end
  else
    directory "/root/.ssh/" do
      owner "root"
      group "root"
      mode 00700
      action :create
    end
    file "/root/.ssh/authorized_keys" do
      owner "root"
      group "root"
      mode "644"
      content File.open("/etc/openshift/rsync_id_rsa.pub").read()
      action :create_if_missing
    end
  end
end
