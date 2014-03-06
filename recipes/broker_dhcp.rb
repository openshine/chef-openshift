#
# Cookbook Name:: openshift
# Recipe:: broker_dhcp
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

OPENSHIFT_BROKER_IP = node['openshift']['broker']['ipaddress'] == '' ? node['ipaddress'] : node['openshift']['broker']['ipaddress']
DNS_IP = node['openshift']['dhcp']['prepend_dns'] == '' ? OPENSHIFT_BROKER_IP : node['openshift']['dhcp']['prepend_dns']

if node['openshift']['dhcp']['enable']
  ruby_block 'preprend openshift dns at dhclient.conf' do
    block do
      if File.exists?('/etc/dhcp/dhclient.conf')
        f = Chef::Util::FileEdit.new('/etc/dhcp/dhclient.conf')
        f.insert_line_if_no_match("prepend.*domain-name-servers.*#{DNS_IP};", "prepend domain-name-servers #{DNS_IP};")
        f.write_file
      else
        File.open('/etc/dhcp/dhclient.conf', 'w+') { |file| file.write("prepend domain-name-servers #{DNS_IP};") }
      end
    end
  end
  execute 'dhclient -r'
  execute 'dhclient'
end
