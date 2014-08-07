
service node['libvirt']['libvirt_service'] do
  action [:enable, :start]
  supports [ :start, :stop, :status, :reload ]
end

unless node['libvirt']['hooks'].nil?

  node['libvirt']['hooks'].each do |name, options|
    next unless options['type'].nil?

    hook_path = ''
    hook_dir = ''

    case options['type']
    when 'daemon', 'qemu', 'lxc', 'network'
      hook_dir = ::File.join(node['libvirt']['conf.d'], 'hooks', options['type'])
      hook_path = ::File.join(hook_dir, name)
    else
      Chef::Log.error('unknown libvirt hook type: ' + options['type'])
    end

    directory hook_dir do
      owner node['libvirt']['user']
      group node['libvirt']['group']
      mode 00750
      recursive true
      action :create
    end

    file hook_path do
      content options['content']
      mode 00750
      owner node['libvirt']['user']
      group node['libvirt']['group']
      action :create
      notifies :reload, "service[#{node['libvirt']['libvirt_service']}]", :delayed
    end
  end
end

template '/etc/libvirt/libvirtd.conf' do
  source 'libvirtd.conf.erb'
  owner node['libvirt']['user']
  group node['libvirt']['group']
  mode 00750
  notifies :reload, "service[#{node['libvirt']['libvirt_service']}]", :delayed
  variables({ :variables => node['libvirt']['libvirtd'] })
end

unless node['libvirt']['libvirt-bin'].nil?
  template '/etc/default/libvirt-bin' do
    source 'libvirt-bin.erb'
    action :create
    mode 00644
    owner 'root'
    group 'root'
    variables({ :vars => node['libvirt']['libvirt-bin'] })
    notifies :reload, "service[#{node['libvirt']['libvirt_service']}]", :delayed
  end
end

unless node['libvirt']['users'].nil?
  group node['libvirt']['group'] do
    members node['libvirt']['users']
    action :manage
  end
end

unless node['libvirt']['networks'].nil?
  node['libvirt']['networks'].each do |k, v|
    libvirt_network k do
      action v['action']
    end
  end
end

unless node['libvirt']['pools'].nil?
  node['libvirt']['pools'].each do |pool|
    case pool['type']
      when 'logical'
      libvirt_pool_logical pool['name'] do
        %w{name source target action uuid}.each do |attr|
          send(attr, pool[attr])  if pool[attr]
        end
      end
    end
  end
end
