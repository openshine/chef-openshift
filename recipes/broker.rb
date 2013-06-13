#
# Cookbook Name:: openshift
# Recipe:: broker
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

include_recipe "ntp"
include_recipe "openshift::broker_named"
include_recipe "openshift::broker_mongodb"
include_recipe "openshift::broker_messaging"

%w{openshift-origin-broker
   openshift-origin-broker-util
   rubygem-openshift-origin-auth-remote-user
   rubygem-openshift-origin-msg-broker-mcollective
   rubygem-openshift-origin-dns-bind}.each do |pkg|

  package "#{pkg}"
end
