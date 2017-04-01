resource_name :libvirt_pool
provides :libvirt_pool

# external properties
property :name, String, name_property: true
property :type, String, identity: true
property :options, Mash, identity: true
property :source, String, identity: true
property :uuid, String, identity: true
property :uri, String, default: 'qemu:///system'

# internal properties
property :autostart, [true, false], default: false, identity: true
property :active, [true, false], default: false, identity: true
property :persistent, [true, false], default: false, identity: true

default_action :create

action_class do
  def exists?
    shell_out!("virsh -c #{uri} pool-info #{name}", environment: { 'LC_ALL' => nil })
    true
  rescue Mixlib::ShellOut::ShellCommandFailed
    false
  end
end

load_current_value do
  cmd = Mixlib::ShellOut.new("virsh -c #{uri} pool-info #{name}", environment: { 'LC_ALL' => nil })
  cmd.run_command
  cmd.stdout.each_line do |line|
    k, v = line.split(':', 2)
    next if v.nil?
    v.gsub!(/\s+/, '')
    case k
    when 'Name'
      name v
    when 'UUID'
      uuid v
    when 'Persistent'
      if v == 'yes'
        persistent true
      else
        persistent false
      end
    when 'State'
      if v == 'running'
        active true
      else
        active false
      end
    when 'Autostart'
      if v == 'yes'
        autostart true
      else
        autostart false
      end
    end
  end
end

action :autostart do
  if !exists?
    Chef::Log.info("libvirt pool #{name} does not exists")
    return
  end
  if autostart
    Chef::Log.info("libvirt pool #{name} already autostarted")
    return
  end
  converge_by "virsh -c #{uri} pool-autostart #{name}..." do
    execute "virsh -c #{uri} pool-autostart #{name}"
  end
end

action :noautostart do
  if !exists?
    Chef::Log.info("libvirt pool #{name} does not exists")
    return
  end
  if !autostart
    Chef::Log.info("libvirt pool #{name} already not autostarted")
    return
  end
  converge_by "virsh -c #{uri} pool-autostart --disable #{name}..." do
    execute "virsh -c #{uri} pool-autostart --disable #{name}"
  end
end

action :start do
  if !exists?
    Chef::Log.info("libvirt pool #{name} does not exists")
    return
  end
  if active
    Chef::Log.info("libvirt pool #{name} already started")
    return
  end
  converge_by "virsh -c #{uri} pool-start #{name}..." do
    execute "virsh -c #{uri} pool-start #{name}"
  end
end

action :create do
  # a mix of built-in Chef resources and Ruby
end

action :destroy do
  if !exists?
    Chef::Log.info("libvirt pool #{name} does not exists")
    return
  end
  if !active
    Chef::Log.info("libvirt pool #{name} already destroyed")
    return
  end
  converge_by "virsh -c #{uri} pool-destroy #{name}..." do
    execute "virsh -c #{uri} pool-destroy #{name}"
  end
end

action :define do
  if exists?
    Chef::Log.info("libvirt pool #{name} already exists")
    return
  end
  # a mix of built-in Chef resources and Ruby
end

action :undefine do
  if !exists?
    Chef::Log.info("libvirt pool #{name} does not exists")
    return
  end
  if !persistent
    Chef::Log.info("libvirt pool #{name} does not defined")
    return
  end
  converge_by "virsh -c #{uri} pool-undefine #{name}..." do
    execute "virsh -c #{uri} pool-undefine #{name}"
  end
end
