#
# Cookbook Name:: openshift
# Recipe:: broker_mongodb
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

package "mongodb-server"

ruby_block 'auth = true -> /etc/mongodb.conf' do
  block do
    f = Chef::Util::FileEdit.new('/etc/mongodb.conf')
    f.search_file_replace("^auth *=.*$","auth = true")
    f.insert_line_if_no_match("^auth *=.*$", "auth = true")
    f.write_file
  end
end

ruby_block 'smallfiles = true -> /etc/mongodb.conf' do
  block do
    f = Chef::Util::FileEdit.new('/etc/mongodb.conf')
    f.search_file_replace("^smallfiles *=.*$", "smallfiles = true")
    f.insert_line_if_no_match("^smallfiles *=.*$", "smallfiles = true")
    f.write_file
  end
end

service "mongod" do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end
