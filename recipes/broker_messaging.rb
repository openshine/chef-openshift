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
FW_ADD_PORT_CMD = node["openshift"]["firewall"]["add_port"]

 
case node["openshift"]["messaging"]["provider"]
when "qpid"
  package "mcollective-qpid-plugin"
  package "qpid-cpp-server"

  execute "Enable qpid firewall" do
    cwd "/etc"
    case node.set["openshift"]["firewall"]["provider"]
    when "firewalld"
      command "#{FW_ADD_PORT_CMD}5672/tcp"
    when "lokkit"
      command "#{FW_ADD_PORT_CMD}5672:tcp"
    end
  end

  service "qpidd" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end
when "activemq"
  package "activemq"
  package "activemq-client"

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

  template "/etc/activemq/activemq.xml" do
    source "activemq/activemq.xml.erb"
    mode 0444
    owner "root"
    group "root"
    variables({ :node_fqdn => "broker.#{OPENSHIFT_DOMAIN}",
                :mq_server_user => node["openshift"]["messaging"]["server"]["user"],
                :mq_server_password => node["openshift"]["messaging"]["server"]["password"]
              })
  end

  template "/etc/activemq/jetty.xml" do
    source "activemq/jetty.xml.erb"
    mode 0444
    owner "root"
    group "root"
  end

  template "/etc/activemq/jetty-realm.properties" do
    source "activemq/jetty-realm.properties.erb"
    mode 0444
    owner "root"
    group "root"
    variables({:mq_server_password => node["openshift"]["messaging"]["server"]["password"]})
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
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

end
