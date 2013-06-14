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

require 'fileutils'

action :add do
  fwd = ""
  if ::File.exists?("/usr/bin/firewall-cmd")
    fwd = "firewalld"
  elsif ::File.exists?("/usr/sbin/lokkit")
    fwd = "lokkit"
  end

  case fwd
  when ""
    log "There isn't firewall client"
  when "firewalld"
    case @new_resource.type
    when "service"
      service = @new_resource.service
      execute "Add #{service} service to firewall" do
        user "root"
        command "/usr/bin/firewall-cmd --add-service=#{service}"
      end
      execute "Add #{service} service to firewall permanently" do
        user "root"
        command "/usr/bin/firewall-cmd --permanent --add-service=#{service}"
      end
    when "port"
      port = @new_resource.port
      protocol = @new_resource.protocol
      execute "Add #{port}/#{protocol} to firewall" do
        user "root"
        command "/usr/bin/firewall-cmd --add-port=#{port}/#{protocol}"
      end
      execute "Add #{port}/#{protocol} to firewall permanently" do
        user "root"
        command "/usr/bin/firewall-cmd --permanent --add-port=#{port}/#{protocol}"
      end
    end
  when "lokkit"
    case @new_resource.type
    when "service"
      service = @new_resource.service
      execute "Add #{service} service to firewall" do
        user "root"
        command "/usr/sbin/lokkit --service=#{service}"
      end
    when "port"
      port = @new_resource.port
      protocol = @new_resource.protocol
      execute "Add #{port}/#{protocol} to firewall" do
        user "root"
        command "/usr/sbin/lokkit --port=#{port}:#{protocol}"
      end
    end
  end
end
