resource_name :libvirt_pool
provides :libvirt_pool

# external properties
property :name, String, name_property: true
property :type, String, identity: true, default: ''
property :options, Mash, identity: true, required: true
property :source, String, identity: true, default: "pool_#{type}.xml.erb"
property :cookbook, String, identity: true, default: 'libvirt'
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

  def create_xml
    template tpl_path? do
      source source
      cookbook cookbook
      backup 0
      atomic_update false
      action :create
      variables(name: name, options: options, uuid: uuid)
    end
  end

  def tpl_path?
    ::File.join("#{Chef::Config['file_cache_path']}", "libvirt-pool-#{name}.xml")
  end

  def remove_xml
    file tpl_path? do
      backup 0
      action :delete
      only_if { ::File.exist?(tpl_file) }
    end
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
  if autostart
    Chef::Log.info("libvirt pool #{name} already autostarted")
    return
  end
  converge_by "virsh -c #{uri} pool-autostart #{name}..." do
    execute "virsh -c #{uri} pool-autostart #{name}" do
      only_if { exist? }
    end
  end
end

action :noautostart do
  if !autostart
    Chef::Log.info("libvirt pool #{name} already not autostarted")
    return
  end
  converge_by "virsh -c #{uri} pool-autostart --disable #{name}..." do
    execute "virsh -c #{uri} pool-autostart --disable #{name}" do
      only_if { exist? }
    end
  end
end

action :start do
  if active
    Chef::Log.info("libvirt pool #{name} already started")
    return
  end
  converge_by "virsh -c #{uri} pool-start #{name}..." do
    execute "virsh -c #{uri} pool-start #{name}" do
      only_if { exist? }
    end
  end
end

action :create do
  create_xml
  case type
  when 'dir'
    directory options['path'] do
      action :create
      mode 0755
    end
  end
  converge_by "virsh -c #{uri} pool-create #{name}..." do
    execute "virsh -c #{uri} pool-create #{tpl_path?}" do
      not_if { exist? }
    end
  end
  remove_xml
end

action :destroy do
  if !active
    Chef::Log.info("libvirt pool #{name} already destroyed")
    return
  end
  converge_by "virsh -c #{uri} pool-destroy #{name}..." do
    execute "virsh -c #{uri} pool-destroy #{name}" do
      only_if { exist? }
    end
  end
end

action :define do
  if persistent
    Chef::Log.info("libvirt pool #{name} already defined")
    return
  end
  create_xml
  converge_by "virsh -c #{uri} pool-define #{name}..." do
    execute "virsh -c #{uri} pool-define #{tpl_path?}" do
      not_if { exist? }
    end
  end
  remove_xml
end

action :undefine do
  if !persistent
    Chef::Log.info("libvirt pool #{name} does not defined")
    return
  end
  converge_by "virsh -c #{uri} pool-undefine #{name}..." do
    execute "virsh -c #{uri} pool-undefine #{name}" do
      only_if { exist? }
    end
  end
end
