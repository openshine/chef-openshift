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

SYNC_ENABLE = node["openshift"]["sync"]["enable"]
SYNC_USER = node["openshift"]["sync"]["user"]
SYNC_PASSWORD = `openssl passwd -1 "#{node["openshift"]["sync"]["password"]}"`
SYNC_UID = node["openshift"]["sync"]["uid"]
SYNC_GID = node["openshift"]["sync"]["gid"]
SYNC_HOME = node["openshift"]["sync"]["home"]

if SYNC_ENABLE
  user SYNC_USER do
    comment "Openshift sync user"
    uid #{SYNC_UID}
    gid #{SYNC_GID}
    home SYNC_HOME
    shell "/bin/bash"
    password SYNC_PASSWORD.strip!
  end

  package "sudo"
  
  ruby_block "Add sync user to sudores to use oo-register-dns" do
    block do
      f = Chef::Util::FileEdit.new('/etc/sudoers')
      f.insert_line_if_no_match("^#{SYNC_USER}.*", "#{SYNC_USER}  ALL=(ALL) NOPASSWD:/sbin/oo-register-dns")
      f.write_file
    end
  end

end
