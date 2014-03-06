#
# Cookbook Name:: openshift
# Recipe:: broker_messaging
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
  package "mcollective-qpid-plugin"
  package "qpid-cpp-server"

  openshift_fwd "Enable qpid firewall" do
    type "port"
    port 5672
    protocol "tcp"
    action :add
  end

  service "qpidd" do
    supports status: true, restart: true, reload: true
    action [ :enable, :start ]
  end
when "activemq"
  case node["openshift"]["messaging"]["server"]["install_method"]
  when "pkg"
    package "activemq"
    activemq_confdir = "/etc/activemq"
  when "source"
    include_recipe "activemq"

    version = node['activemq']['version']
    activemq_confdir = "#{node['activemq']['home']}/apache-activemq-#{version}/conf"
  end

  case node["platform"]
  when "fedora"
    template "/etc/tmpfiles.d/activemq.conf" do
      source "activemq/tmp-activemq.conf.erb"
      mode 0755
      owner "root"
      group "root"
    end
  end

  directory "/var/run/activemq" do
    owner "activemq"
    group "activemq"
    mode 00750
    action :create
  end

  template "#{activemq_confdir}/activemq.xml" do
    source "activemq/activemq.xml.erb"
    mode 0444
    owner "root"
    group "root"
    variables(node_fqdn: "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}",
              mq_server_user: node["openshift"]["messaging"]["server"]["user"],
              mq_server_password: node["openshift"]["messaging"]["server"]["password"]
              )
  end

  template "#{activemq_confdir}/jetty.xml" do
    source "activemq/jetty.xml.erb"
    mode 0444
    owner "root"
    group "root"
  end

  template "#{activemq_confdir}/jetty-realm.properties" do
    source "activemq/jetty-realm.properties.erb"
    mode 0444
    owner "root"
    group "root"
    variables(mq_server_password: node["openshift"]["messaging"]["server"]["password"])
  end

  openshift_fwd "Enable activemq firewall" do
    type "port"
    port 616_13
    protocol "tcp"
    action :add
  end

  execute "Enable activemq firewall" do
    cwd "/etc"
    case node.set["openshift"]["firewall"]["provider"]
    when "firewalld"
      command "#{FW_ADD_PORT_CMD}61613/tcp"
    when "lokkit"
      command "#{FW_ADD_PORT_CMD}61613:tcp"
    end
  end

  service "activemq" do
    supports status: true, restart: true, reload: true
    action [ :enable, :start ]
  end

end

package "mcollective-client"

template "/etc/mcollective/client.cfg" do
  source "mcollective-client-cfg.erb"
  mode 0755
  owner "root"
  group "root"
  variables(platform: node["platform"],
            mq_provider: node["openshift"]["messaging"]["provider"],
            mq_fqdn: "#{OPENSHIFT_BROKER_HOSTNAME}.#{OPENSHIFT_DOMAIN}",
            mq_server_user: node["openshift"]["messaging"]["server"]["user"],
            mq_server_password: node["openshift"]["messaging"]["server"]["password"]
            )
end
