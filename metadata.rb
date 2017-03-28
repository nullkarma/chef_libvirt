name 'libvirt'
maintainer 'Vasiliy Tolstov'
maintainer_email 'v.tolstov@selfip.ru'
license 'MIT'
description 'Installs/configures libvirt'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'

recipe 'libvirt',       'Installs libvirt package and sets up configuration'

%w(sheepdog openvswitch systemd blockdev filesystem).each do |dep|
  depends dep
end

%w(debian ubuntu suse exherbo centos fedora).each do |os|
  supports os
end
