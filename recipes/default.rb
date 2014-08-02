
service node['libvirt']['libvirt_service'] do
  action [:enable, :start]
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

unless node['libvirt']['network'].nil?
  node['libvirt']['network'].each do |k, v|
    network k do
      action v['action']
    end
  end
end
