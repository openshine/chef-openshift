name             "openshift"
maintainer       "Roberto Majadas"
maintainer_email "roberto.majadas@openshine.com"
license          "Apache 2.0"
description      "Installs/Configures openshift"

version          "0.0.1"

%w{ yum ntp activemq hostsfile }.each do |dep|
  depends dep
end

%w{ redhat fedora }.each do |os|
  supports os
end
