
service node['libvirt']['libvirt_service'] do
  action [:enable, :start]
  supports [:start, :stop, :status, :reload, :restart]
end

%w(libvirt libvirtd lxc qemu qemu-lockd virtlockd virt-login-shell).each do |name|
  template "/etc/libvirt/#{name}.conf" do
    source "#{name}.conf.erb"
    owner node['libvirt']['user']
    group node['libvirt']['group']
    mode 00750
    notifies :restart, "service[#{node['libvirt']['libvirt_service']}]", :delayed
    variables(variables: node['libvirt'][name])
    not_if { node['libvirt'][name].nil? || node['libvirt'][name].empty? }
  end
end

unless node['libvirt']['libvirt-bin'].nil? && node['libvirt']['libvirt-bin'].empty?
  filename = ''
  filesource = ''
  case node['platform']
  when 'debian', 'ubuntu'
    filename = '/etc/default/libvirt-bin'
    filesource = 'libvirt-bin.debian.erb'
  when 'exherbo'
    filename = '/etc/conf.d/libvirt'
    filesource = 'libvirt-bin.exherbo.erb'
  end

  template filename do
    source filesource
    action :create
    mode 00644
    owner 'root'
    group 'root'
    variables(vars: node['libvirt']['libvirt-bin'])
    notifies :restart, "service[#{node['libvirt']['libvirt_service']}]", :delayed
    not_if { filename.empty? || filesource.empty? }
  end
end

group node['libvirt']['group'] do
  members node['libvirt']['users']
  action :manage
  not_if { node['libvirt']['users'].nil? }
end

domains = Mash.new
nwfilters = Mash.new
networks = Mash.new
pools = Mash.new
hooks = Mash.new

unless node['libvirt']['data_bags'].nil? && node['libvirt']['data_bag'].nil?
  node['libvirt']['data_bags'].each do |item|
    bag_item  = begin
      if node['libvirt']['data_bag_secret']
        secret = Chef::EncryptedDataBagItem.load_secret(node['libvirt']['data_bag_secret'])
        Chef::EncryptedDataBagItem.load(node['libvirt']['data_bag'], item, secret)
      else
        data_bag_item(node['libvirt']['data_bag'], item)
      end
    rescue => ex
      Chef::Log.info("Data bag #{bag} not found (#{ex}), so skipping")
      {}
    end

    if bag_item['domain']
      domains = Chef::Mixin::DeepMerge.merge(domains, bag_item['domain'])
    end

    if bag_item['nwfilter']
      nwfilters = Chef::Mixin::DeepMerge.merge(nwfilters, bag_item['nwfilter'])
    end

    if bag_item['network']
      networks = Chef::Mixin::DeepMerge.merge(networks, bag_item['network'])
    end

    if bag_item['pool']
      pools = Chef::Mixin::DeepMerge.merge(pools, bag_item['pool'])
    end

    if bag_item['hook']
      hooks = Chef::Mixin::DeepMerge.merge(hooks, bag_item['hook'])
    end
  end

  node.set['libvirt']['domains'] = domains
  node.set['libvirt']['nwfilters'] = nwfilters
  node.set['libvirt']['networks'] = networks
  node.set['libvirt']['pools'] = pools
  node.set['libvirt']['hooks'] = hooks
  include_recipe 'libvirt'
end

unless node['libvirt']['networks'].nil?
  node['libvirt']['networks'].each do |net|
    libvirt_network net['name'] do
      %w(name uuid type options action returns).each do |attr|
        send(attr, net[attr]) if net[attr]
      end
    end
  end
end

# unless node['libvirt']['hooks'].nil?
#  node['libvirt']['hooks'].each do |hook|
#    libvirt_hook hook['name'] do
#      %w{name source}.each do |attr|
#        send(attr, hook[attr]) if hook[attr]
#      end
#    end
#  end
# end

unless node['libvirt']['pools'].nil?
  node['libvirt']['pools'].each do |name, values|
    libvirt_pool name do
      %w(type options action returns).each do |attr|
        send(attr, values[attr]) if values[attr]
      end
    end
  end
end
