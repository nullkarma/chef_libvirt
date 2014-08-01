domains = Mash.new
nwfilters = Mash.new
networks = Mash.new
pools = Mash.new
hooks = Mash.new

bag = node['libvirt']['data_bag']

unless node['libvirt']['data_bags'].nil?
  node['libvirt']['data_bags'].each do |item|
    bag_item  = begin
      if node['libvirt']['secret']
        secret = Chef::EncryptedDataBagItem.load_secret(node['libvirt']['secret'])
        Chef::EncryptedDataBagItem.load(bag, item, secret)
      else
        data_bag_item(bag, item)
      end
    rescue => ex
      Chef::Log.info("Data bag #{bag} not found (#{ex}), so skipping")
      Hash.new
    end

    if bag_item['domains']
      domains = Chef::Mixin::DeepMerge.merge(domains, bag_item['domains'])
    end

    if bag_item['nwfilters']
      nwfilters = Chef::Mixin::DeepMerge.merge(nwfilters, bag_item['nwfilters'])
    end

    if bag_item['networks']
      networks = Chef::Mixin::DeepMerge.merge(networks, bag_item['networks'])
    end

    if bag_item['pools']
      pools = Chef::Mixin::DeepMerge.merge(pools, bag_item['pools'])
    end

    if bag_item['hooks']
      pools = Chef::Mixin::DeepMerge.merge(hooks, bag_item['hooks'])
    end

  end

  node.set['libvirt']['domains'] = domains
  node.set['libvirt']['nwfilters'] = nwfilters
  node.set['libvirt']['networks'] = networks
  node.set['libvirt']['pools'] = pools
  node.set['libvirt']['hooks'] = hooks
  include_recipe 'libvirt'
end
