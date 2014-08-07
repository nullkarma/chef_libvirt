use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :destroy do
  execute "virsh net-destroy #{new_resource.name}" do
    command "virsh net-destroy #{new_resource.name}"
    not_if { Mixlib::ShellOut.new("virsh net-list | grep -q #{new_resource.name}") }
  end
  new_resource.updated_by_last_action(true)
end

action :undefine do
  execute "virsh net-undefine #{new_resource.name}" do
    command "virsh net-undefine #{new_resource.name}"
    not_if { Mixlib::ShellOut.new("virsh net-info #{new_resource.name}") }
  end
  new_resource.updated_by_last_action(true)
end
