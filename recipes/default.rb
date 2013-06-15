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

OPENSHIFT_DOMAIN = node["openshift"]["domain"]
OPENSHIFT_BROKER_IP = node["openshift"]["broker"]["ipaddress"] == "" ? node["ipaddress"] : node["openshift"]["broker"]["ipaddress"]
OPENSHIFT_BROKER_HOSTNAME = node["openshift"]["broker"]["hostname"]
OPENSHIFT_NODE_IP = node["openshift"]["node"]["ipaddress"] == "" ? node["ipaddress"] : node["openshift"]["node"]["ipaddress"]
OPENSHIFT_NODE_HOSTNAME = node["openshift"]["node"]["hostname"]

case node["platform"]
when "redhat","centos","fedora"
  include_recipe "yum"

  #Register yum repositories
  # yum_repository "openshift" do
  #   description "openshift"
  #   case node["platform"]
  #   when "fedora"
  #     url "https://mirror.openshift.com/pub/origin-server/fedora-$releasever/$basearch/"
  #   when "centos", "redhat"
  #     url "https://mirror.openshift.com/pub/origin-server/rhel-$releasever/$basearch/"
  #   end
  #   action platform?('amazon') ? [:add, :update] : :add
  # end

  # yum_repository "openshift-nightly" do
  #   description "openshift nightly"
  #   case node["platform"]
  #   when "fedora"
  #     url "https://mirror.openshift.com/pub/origin-server/nightly/fedora-$releasever/latest/$basearch/"
  #   when "centos", "redhat"
  #     url "https://mirror.openshift.com/pub/origin-server/nightly/rhel-$releasever/latest/$basearch/"
  #   end
  #   action platform?('amazon') ? [:add, :update] : :add
  # end

  if node["openshift"]["broker"]["enable"]
    ip = node["ipaddress"]
    hostsfile_entry "#{OPENSHIFT_BROKER_IP}" do
      hostname "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
      comment   "openshift broker domain"
      action    :create_if_missing
    end

    include_recipe "openshift::broker"
  end

  if node["openshift"]["node"]["enable"]
    hostsfile_entry "#{OPENSHIFT_NODE_IP}" do
      hostname "#{OPENSHIFT_NODE_HOSTNAME}.#{OPENSHIFT_DOMAIN}"
      comment "openshift node"
      action    :append
    end
    include_recipe "openshift::node"
  end
end
