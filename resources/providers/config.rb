# Cookbook:: rbnmsp
# Provider:: config

action :add do
  begin
    config_dir = new_resource.config_dir
    flow_nodes = new_resource.flow_nodes
    proxy_nodes = new_resource.proxy_nodes
    memory = new_resource.memory
    hosts = new_resource.hosts
    mode = new_resource.mode

    dnf_package 'redborder-nmsp' do
      action :upgrade
    end

    directory config_dir do
      owner 'root'
      group 'root'
      mode '755'
      action :create
    end

    # Retrieve databag data
    begin
      db_redborder = data_bag_item('passwords', 'db_redborder')
    rescue
      db_redborder = {}
    end

    unless db_redborder.empty?
      psql_name = db_redborder['database']
      psql_user = db_redborder['username']
      psql_password = db_redborder['pass']
      psql_port = db_redborder['port']
    end

    template '/etc/redborder-nmsp/config.yml' do
      source 'rb-nmsp_config.yml.erb'
      cookbook 'rbnmsp'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(zk_hosts: hosts,
                flow_nodes: flow_nodes,
                cloudproxy_nodes: proxy_nodes,
                db_name: psql_name,
                db_hostname: db_redborder['hostname'],
                db_pass: psql_password,
                db_username: psql_user,
                db_port: psql_port,
                mode: mode)
      notifies :restart, 'service[redborder-nmsp]', :delayed
      action :create
    end

    template '/etc/sysconfig/redborder-nmsp' do
      source 'rb-nmsp_sysconfig.erb'
      cookbook 'rbnmsp'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(memory: memory)
      notifies :restart, 'service[redborder-nmsp]', :delayed
    end

    begin
      nmsp_keys = data_bag_item('passwords', 'nmspd-key-hashes')
    rescue
      nmsp_keys = nil
    end

    if nmsp_keys
      cookbook_file '/etc/redborder-nmsp/aes.keystore' do
        source 'aes.keystore'
        cookbook 'rbnmsp'
        owner 'root'
        group 'root'
        mode '0644'
        ignore_failure true
        notifies :restart, 'service[redborder-nmsp]', :delayed
      end
    end

    service 'redborder-nmsp' do
      service_name 'redborder-nmsp'
      ignore_failure true
      supports status: true, reload: true, restart: true
      action [:enable, :start]
    end

    Chef::Log.info('cookbook redborder-nmsp has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redborder-nmsp' do
      service_name 'redborder-nmsp'
      supports status: true, restart: true, start: true, enable: true, disable: true
      action [:disable, :stop]
    end
    Chef::Log.info('cookbook redborder-nmsp has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['redborder-nmsp']['registered']
      query = {}
      query['ID'] = "redborder-nmsp-#{node['hostname']}"
      query['Name'] = 'redborder-nmsp'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 16113
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-nmsp']['registered'] = true
    end
    Chef::Log.info('redborder-nmsp service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['redborder-nmsp']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/redborder-nmsp-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-nmsp']['registered'] = false
    end
    Chef::Log.info('redborder-nmsp service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :configure_keys do
  begin
    nmsp_keys = data_bag_item('passwords', 'nmspd-key-hashes')
  rescue
    nmsp_keys = nil
  end

  begin
    if nmsp_keys.nil?
      execute 'Configure service keys' do
        command '/usr/lib/redborder/bin/rb_create_nmsp_keys.sh -fu &>> /var/log/configure_nmsp_keys.log'
        action :nothing
      end.run_action(:run)

      Chef::Log.info('rb-nmsp service keys has been configured')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
