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
      pools = Chef::Mixin::DeepMerge.merge(hooks, bag_item['hook'])
    end

  end

  node.set['libvirt']['domains'] = domains
  node.set['libvirt']['nwfilters'] = nwfilters
  node.set['libvirt']['networks'] = networks
  node.set['libvirt']['pools'] = pools
  node.set['libvirt']['hooks'] = hooks
  include_recipe 'libvirt'
end
