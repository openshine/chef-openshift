#
# Cookbook Name:: openshift
# Recipe:: node_messaging
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

case node["openshift"]["messaging"]["provider"]
when "qpid"
  package "openshift-origin-msg-node-mcollective"
  package "mcollective"

  template "/etc/mcollective/server.cfg" do
    source "mcollective-server-cfg.erb"
    mode 0755
    owner "root"
    group "root"
    variables({ :platform => node["platform"],
                :mq_provider => node["openshift"]["messaging"]["provider"],
                :mq_fqdn => "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}",
                :mq_server_user => node["openshift"]["messaging"]["server"]["user"],
                :mq_server_password => node["openshift"]["messaging"]["server"]["password"]
              })
  end
end

service "mcollective" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
