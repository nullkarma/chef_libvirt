
service node['libvirt']['libvirt_service'] do
  action [:enable, :start]
  supports [ :start, :stop, :status, :reload, :restart ]
end

template '/etc/libvirt/libvirtd.conf' do
  source 'libvirtd.conf.erb'
  owner node['libvirt']['user']
  group node['libvirt']['group']
  mode 00750
  notifies :restart, "service[#{node['libvirt']['libvirt_service']}]", :delayed
  variables({ :variables => node['libvirt']['libvirtd'] })
end

template '/etc/libvirt/qemu.conf' do
  source 'qemu.conf.erb'
  owner node['libvirt']['user']
  group node['libvirt']['group']
  mode 00750
  notifies :restart, "service[#{node['libvirt']['libvirt_service']}]", :delayed
  variables({ :variables => node['libvirt']['qemu'] })
end

unless node['libvirt']['libvirt-bin'].nil?
  template '/etc/default/libvirt-bin' do
    source 'libvirt-bin.erb'
    action :create
    mode 00644
    owner 'root'
    group 'root'
    variables({ :vars => node['libvirt']['libvirt-bin'] })
    notifies :restart, "service[#{node['libvirt']['libvirt_service']}]", :delayed
  end
end

unless node['libvirt']['users'].nil?
  group node['libvirt']['group'] do
    members node['libvirt']['users']
    action :manage
  end
end

unless node['libvirt']['networks'].nil?
  node['libvirt']['networks'].each do |net|
    case net['type']
    when 'bridge'
      libvirt_net_bridge net['name'] do
        %w{name action uuid}.each do |attr|
          send(attr, net[attr]) if net[attr]
        end
      end
    else
      libvirt_network net['name'] do
        %w{name action uuid}.each do |attr|
          send(attr, net[attr]) if net[attr]
        end
      end
    end
  end
end

unless node['libvirt']['hooks'].nil?
  node['libvirt']['hooks'].each do |hook|
    libvirt_hook hook['name'] do
      %w{name source}.each do |attr|
        send(attr, hook[attr]) if hook[attr]
      end
    end
  end
end

unless node['libvirt']['pools'].nil?
  node['libvirt']['pools'].each do |pool|
    case pool['type']
      when 'logical'
      libvirt_pool_logical pool['name'] do
        %w{name source target action uuid}.each do |attr|
          send(attr, pool[attr]) if pool[attr]
        end
      end
    end
  end
end
