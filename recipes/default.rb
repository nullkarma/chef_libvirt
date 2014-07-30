
unless node['libvirt']['hooks'].nil?

  node['libvirt']['hooks'].each do |name, options|
    next unless options['type'].nil?

    hook_path = ""
    hook_dir = ""

    case options['type']
    when 'daemon','qemu','lxc','network'
      hook_dir = ::File.join(node['libvirt']['conf.d'], 'hooks', options['type'])
      hook_path = ::File.join(hook_dir, name)
    else
      Chef::Log.error("unknown libvirt hook type: " + options['type'])
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
      notifies :reload, "service[#{node['libvirt']['service_name']}]", :delayed
    end

  end

end
