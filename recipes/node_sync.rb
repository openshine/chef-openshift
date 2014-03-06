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
OPENSHIFT_BROKER_IP = node["openshift"]["broker"]["ipaddress"]

SYNC_ENABLE = node["openshift"]["sync"]["enable"]
SYNC_USER = node["openshift"]["sync"]["user"]
SYNC_PASSWORD = node["openshift"]["sync"]["password"]
SYNC_HOME = node["openshift"]["sync"]["home"]

if SYNC_ENABLE
  directory "/root/.ssh/" do
    owner "root"
    group "root"
    mode 00700
    action :create
  end

  chef_gem "net-sftp"
  ruby_block 'Save rsync_id_rsa.pub from broker' do
    block do
      require 'net/sftp'
      Net::SFTP.start(OPENSHIFT_BROKER_IP,
                      SYNC_USER, password: SYNC_PASSWORD) do |sftp|
        data = sftp.download!("#{SYNC_HOME}/rsync_id_rsa.pub").strip!

        if File.exists?("/root/.ssh/authorized_keys")
          f = Chef::Util::FileEdit.new('/root/.ssh/authorized_keys')
          f.insert_line_if_no_match(data, data)
          f.write_file
        else
          File.open("/root/.ssh/authorized_keys", "w+") { |file| file.write(data) }
        end
      end
    end
  end

  chef_gem "net-ssh"
  ruby_block 'Register node domain at broker dns' do
    block do
      require 'net/ssh'

      Net::SSH.start(OPENSHIFT_BROKER_IP,
                     SYNC_USER, password: SYNC_PASSWORD) do |ssh|
        ssh.open_channel do |ch|
          ch.request_pty
          res = ch.exec "sudo /sbin/oo-register-dns -s 127.0.0.1 -h #{OPENSHIFT_NODE_HOSTNAME} -d #{OPENSHIFT_DOMAIN} -n #{OPENSHIFT_NODE_IP} -k /var/named/#{OPENSHIFT_DOMAIN}.key"
        end
      end
    end
  end

end
