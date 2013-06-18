#
# Cookbook Name:: openshift
# Recipe:: node_security
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

service "sshd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

ruby_block "Tweak /etc/ssh/sshd_config" do
  block do
    f = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    f.search_file_replace("^(#|)MaxSessions.*", "MaxSessions 40")
    f.search_file_replace("^(#|)MaxStartups.*", "MaxStartups 40")
    f.write_file
  end
end

ruby_block "Tweak /etc/ssh/sshd_config (second pass)" do
  block do
    f = Chef::Util::FileEdit.new("/etc/ssh/sshd_config")
    f.insert_line_if_no_match(".*GIT_SSH.*", "AcceptEnv GIT_SSH")
    f.write_file
  end
end

openshift_fwd "Enable ssh firewall" do
  type "service"
  service "ssh"
  action :add
end

openshift_fwd "Enable http firewall" do
  type "service"
  service "http"
  action :add
end

openshift_fwd "Enable https firewall" do
  type "service"
  service "https"
  action :add
end

#PAM configuration
ruby_block "Tweak /etc/pam.d/sshd" do
  block do
    f = Chef::Util::FileEdit.new("/etc/pam.d/sshd")
    f.search_file_replace("pam_selinux", "pam_openshift")
    f.write_file
  end
end

%w{runuser runuser-l sshd su system-auth-ac}.each do |t|
  ruby_block "Tweak /etc/pam.d/#{t}" do
    block do
      f = Chef::Util::FileEdit.new("/etc/pam.d/#{t}")
      f.insert_line_if_no_match(".*pam_namespace.so.*", "session\t\trequired\tpam_namespace.so no_unmount_on_close")
      f.write_file
    end
  end
end

service "sshd" do
  supports :status => true, :restart => true, :reload => true
  action [ :restart ]
end

#SELinux
execute "set selinux policies" do
  cwd "/etc"
  user "root"
  command "setsebool -P httpd_unified=on httpd_can_network_connect=on httpd_can_network_relay=on httpd_read_user_content=on httpd_enable_homedirs=on httpd_run_stickshift=on allow_polyinstantiation=on"
end

execute "restorecon -rv /var/run"
execute "restorecon -rv /usr/sbin/mcollectived /var/log/mcollective.log /var/run/mcollective*.pid"
execute "restorecon -rv /var/lib/openshift /etc/openshift/node.conf /etc/httpd/conf.d/openshift"
