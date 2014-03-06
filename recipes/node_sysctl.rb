#
# Cookbook Name:: openshift
# Recipe:: node_sysctl
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

template '/etc/sysctl.d/openshift.conf' do
  source 'node/sysctl.d/openshift.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
end

execute 'sysctl -p /etc/sysctl.d/openshift.conf'
