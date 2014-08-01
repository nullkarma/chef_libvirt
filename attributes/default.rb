default['libvirt']['hooks'] = []
default['libvirt']['packages'] = value_for_platform(
  %w(centos redhat suse fedora) => {
    'default' => 'libvirt'
  },
  %w(exherbo archlinux) => {
    'default' => 'libvirt'
  },
  %w(ubuntu debian) => {
    'default' => ['libvirt-bin']
  }
)
default['libvirt']['service'] = value_for_platform(
  %w(centos redhat suse fedora) => {
    'default' => 'libvirt'
  },
  %w(exherbo archlinux) => {
    'default' => 'libvirtd'
  },
  %w(ubuntu debian) => {
    'default' => ['libvirt-bin']
  }
)

default['libvirt']['conf.d'] = '/etc/libvirt'
