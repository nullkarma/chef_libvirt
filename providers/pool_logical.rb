use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :create do
  template "/tmp/pool-#{new_resource.name}.xml" do
    source "pool_logical.xml.erb"
    action :create
    variables(:name => new_resource.name, :target => new_resource.target, :source => new_resource.source, :uuid => new_resource.uuid)
  end
  execute "virsh pool-define /tmp/pool-#{new_resource.name}.xml" do
    command "virsh pool-define /tmp/pool-#{new_resource.name}.xml"
    not_if "virsh pool-info #{new_resource.name} "
  end
  execute "virsh pool-start #{new_resource.name}" do
    command "virsh pool-start #{new_resource.name}"
    not_if "virsh pool-list | grep -q #{new_resource.name}"
  end
end
