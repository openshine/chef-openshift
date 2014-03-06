#
# Cookbook Name:: openshift
# Recipe:: node_quota
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

ruby_block 'Tweak /etc/fstab to add support for user quotas' do
  block do
    FS = `LANG=C df /var/lib | grep -v Filesystem | awk '{print $6}'`.strip!
    if not system("grep \"[[:space:]]#{FS}[[:space:]] .*usrquota\" /etc/fstab > /dev/null")
      system("sed -e \"s|^\\S*\\s\\+#{FS}\\s\\+\\S*\\s\\+|&usrquota,|\" -i /etc/fstab")
      system("mount -o remount #{FS}")
    end
  end
end
