default['libvirt']['hooks'] = []
default['libvirt']['packages'] = value_for_platform(
  [ 'centos', 'redhat', 'suse', 'fedora' ] => {
    'default' => 'libvirt'
  },
  [ 'exherbo', 'archlinux' ] => {
    'default' => 'libvirt'
  },
  [ 'ubuntu', 'debian'] => {
    'default' => [ 'libvirt-bin' ]
  }
)
default['libvirt']['service'] = value_for_platform(
  [ 'centos', 'redhat', 'suse', 'fedora' ] => {
    'default' => 'libvirt'
  },
  [ 'exherbo', 'archlinux' ] => {
    'default' => 'libvirtd'
  },
  [ 'ubuntu', 'debian'] => {
    'default' => [ 'libvirt-bin' ]
  }
)

default['libvirt']['conf.d'] = '/etc/libvirt'
