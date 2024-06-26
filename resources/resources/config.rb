# Cookbook:: rbnmsp
# Resource:: config

actions :add, :remove, :configure_keys, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/redborder-nmsp'
attribute :kafka_topic, kind_of: String, default: 'rb_nmsp'
attribute :name, kind_of: String, default: 'localhost'
attribute :ip, kind_of: String, default: '127.0.0.1'
attribute :flow_nodes, kind_of: Array, default: []
attribute :proxy_nodes, kind_of: Array, default: []
attribute :memory, kind_of: Integer, default: 0
attribute :hosts, kind_of: Object
attribute :mode, kind_of: String, default: 'manager'
