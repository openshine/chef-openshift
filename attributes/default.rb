#openshift general attribs
default["openshift"]["domain"] = "example.com"

#openshift broker attribs
default["openshift"]["broker"]["hostname"] = "broker"
default["openshift"]["broker"]["ipaddress"] = ""

#openshift node attribs
default["openshift"]["node"]["hostname"] = "node1"
default["openshift"]["node"]["ipaddress"] = ""

#openshift broker attribs
default["openshift"]["broker"]["enable"] = true

#openshift node attribs
default["openshift"]["node"]["enable"] = true

#openshift named conf
default["openshift"]["named"]["forwarders"] = ["8.8.8.8", "8.8.4.4"]

#openshift messaging conf
default["openshift"]["messaging"]["provider"] = "qpid"
default["openshift"]["messaging"]["server"]["user"] = "mcollective"
default["openshift"]["messaging"]["server"]["password"] = "marionette"
default["openshift"]["messaging"]["server"]["install_method"] = "pkg"


