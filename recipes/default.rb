#
# Cookbook Name:: openshift
# Recipe:: default
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

case node["platform"]
when "redhat","centos","fedora"
  include_recipe "yum::epel"

  #Check firewall system
  if File.exists?("/usr/bin/firewall-cmd")
    node.set["openshift"]["firewall"]["add_service"] = "/usr/bin/firewall-cmd --permanent --zone=public --add-service="
    node.set["openshift"]["firewall"]["add_port"] = "/usr/bin/firewall-cmd --permanent --zone=public --add-port="
  elsif File.exists?("/usr/sbin/lokkit")
    node.set["openshift"]["firewall"]["add_service"] = "/usr/sbin/lokkit --service="
    node.set["openshift"]["firewall"]["add_port"] = "/usr/sbin/lokkit --port="
  end

  if node["openshift"]["broker"]["enable"]
    include_recipe "openshift::broker"
  end

  if node["openshift"]["node"]["enable"]
    include_recipe "openshift::node"
  end
end
