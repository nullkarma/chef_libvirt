use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :destroy do
  execute "virsh net-destroy #{new_resource.name}" do
    command "virsh net-destroy #{new_resource.name}"
    not_if { "virsh net-list | grep -q #{new_resource.name}" }
  end
  new_resource.updated_by_last_action(true)
end

action :undefine do
  execute "virsh net-undefine #{new_resource.name}" do
    command "virsh net-undefine #{new_resource.name}"
    not_if { "virsh net-info #{new_resource.name}" }
  end
  new_resource.updated_by_last_action(true)
end

action :start do
  execute "virsh net-start #{new_resource.name}" do
    command "virsh net-start #{new_resource.name}"
    not_if "virsh net-list | grep -q #{new_resource.name}"
  end
end

action :autostart do
  execute "virsh net-autostart #{new_resource.name}" do
    command "virsh net-autostart #{new_resource.name}"
    not_if "virsh net-list --autostart | grep -q #{new_resource.name}"
  end
end

action :unautostart do
  execute "virsh net-autostart --disable #{new_resource.name}" do
    command "virsh net-autostart --disable #{new_resource.name}"
    only_if "virsh net-list --autostart | grep -q #{new_resource.name}"
  end
end
