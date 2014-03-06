# openshift general attribs
default['openshift']['domain'] = 'example.com'

# openshift nightly builds repostories
default['openshift']['nightly']['enable'] = false

# openshift broker attribs
default['openshift']['broker']['hostname'] = 'broker'
default['openshift']['broker']['ipaddress'] = ''

# openshift node attribs
default['openshift']['node']['hostname'] = 'node1'
default['openshift']['node']['ipaddress'] = ''

# openshift dhcp conf
default['openshift']['dhcp']['enable'] = false
default['openshift']['dhcp']['prepend_dns'] = ''

# openshift named conf
default['openshift']['named']['forwarders'] = ['8.8.8.8', '8.8.4.4']

# openshift messaging conf
default['openshift']['messaging']['provider'] = 'qpid'
default['openshift']['messaging']['server']['user'] = 'mcollective'
default['openshift']['messaging']['server']['password'] = 'marionette'
default['openshift']['messaging']['server']['install_method'] = 'pkg'

# openshift sync broker<->node
default['openshift']['sync']['enable'] = false
default['openshift']['sync']['user'] = 'oshiftsync'
default['openshift']['sync']['password'] = 'oshiftsync'
default['openshift']['sync']['uid'] = 59_012
default['openshift']['sync']['gid'] = 59_012
default['openshift']['sync']['home'] = '/home/oshiftsync'

# openshift avahi support
default['openshift']['avahi']['enable'] = false
