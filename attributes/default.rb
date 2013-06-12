#openshift general attribs
default["openshift"]["domain"] = "example.com"

#openshift broker attribs
default["openshift"]["broker"]["enable"] = true

#openshift node attribs
default["openshift"]["node"]["enable"] = true

#openshift named conf
default["openshift"]["named"]["forwarders"] = ["8.8.8.8", "8.8.4.4"]

#openshift messaging conf
default["openshift"]["messaging"]["provider"] = "activemq"
default["openshift"]["messaging"]["server"]["user"] = "mcollective"
default["openshift"]["messaging"]["server"]["password"] = "marionette"