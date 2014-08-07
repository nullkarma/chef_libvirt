use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :create do
  file "/etc/libvirt/hooks/#{new_resource.name}" do
    owner node['libvirt']['user']
    group node['libvirt']['group']
    mode 0644
    content new_resource.source.join("\n")
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  file "/etc/libvirt/hooks/#{new_resource.name}" do
    action :delete
    only_if { ::File.exist?("/etc/libvirt/hooks/#{new_resource.name}") }
  end
  new_resource.updated_by_last_action(true)
end
