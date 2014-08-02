use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :destroy do
  virsh = Mixlib::ShellOut.new("virsh net-destroy #{new_resource.name}")
  virsh.run_command
end
