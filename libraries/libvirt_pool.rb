# -*- coding: utf-8 -*-
include Chef::Mixin::ShellOut

class Chef
  class Resource
    # libvirt pool resource
    class LibvirtPool < Chef::Resource
      identity_attr :name

      # rubocop:disable MethodLength
      def initialize(name, run_context = nil)
        super
        @resource_name = :libvirt_pool
        @provider = Chef::Provider::LibvirtPool
        @action = :create
        @allowed_actions = [:define, :create, :undefine, :destroy, :autostart, :start, :noautostart]
        @name = name
        @returns = [0]
        @uuid = nil
        @type = nil
        @source = nil
        @options = nil
      end

      def uuid(arg = nil)
        set_or_return(:uuid, arg, kind_of: [String])
      end

      def type(arg = nil)
        set_or_return(:type, arg, kind_of: [String])
      end

      def source(arg = nil)
        set_or_return(:source, arg, kind_of: [String])
      end

      def options(arg = nil)
        set_or_return(:options, arg, kind_of: [Hash, Mash])
      end

      def returns(arg = nil)
        set_or_return(:returns, arg, kind_of: [Array])
      end
    end
  end
end

class Chef
  class Provider
    # libvirt pool provider
    class LibvirtPool < Chef::Provider
      # implement load_current_resource method to load previous resource before action
      def load_current_resource
        @current_resource = Chef::Resource::LibvirtPool.new(@new_resource.name)
        @current_resource.name(@new_resource.name)
        @current_resource.uuid(@new_resource.uuid)
        @current_resource.source(@new_resource.source)
        @current_resource.options(@new_resource.options)
        @current_resource.returns(@new_resource.returns)
        @current_resource
      end

      def exist?(name)
        Mixlib::ShellOut.new("virsh pool-info #{name}", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def active?(name)
        Mixlib::ShellOut.new("virsh pool-info #{name} | grep -qE '^State:.*running$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def persistent?(name)
        Mixlib::ShellOut.new("virsh pool-info #{name} | grep -qE '^Persistent:.*yes$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def autostart?(name)
        Mixlib::ShellOut.new("virsh pool-info #{name} | grep -qE '^Autostart:.*yes$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def create_xml
        template "/tmp/pool-#{new_resource.name}.xml" do
          source "pool_#{new_resource.type}.xml.erb"
          action :nothing
          variables(name: new_resource.name, options: new_resource.options, uuid: new_resource.uuid)
        end.run_action(:create)
      end

      def remove_xml
        file "/tmp/pool-#{new_resource.name}.xml" do
          backup 0
          action :nothing
          only_if { ::File.exist?("/tmp/pool-#{new_resource.name}.xml") }
        end.run_action(:delete)
      end

      def action_create
        create_xml if new_resource.source.nil? || new_resource.empty?
        execute "virsh pool-create /tmp/pool-#{new_resource.name}.xml" do
          command "virsh pool-create /tmp/pool-#{new_resource.name}.xml"
          not_if { exist?(new_resource.name) }
          returns new_resource.returns
          action :nothing
        end.run_action(:run)
        remove_xml if new_resource.source.nil? || new_resource.empty?
      end

      def action_define
        create_xml if new_resource.source.nil? || new_resource.empty?
        execute "virsh pool-define /tmp/pool-#{new_resource.name}.xml" do
          command "virsh pool-define /tmp/pool-#{new_resource.name}.xml"
          not_if { exist?(new_resource.name) }
          returns new_resource.returns
          action :nothing
        end.run_action(:run)
        remove_xml if new_resource.source.nil? || new_resource.empty?
      end

      def action_start
        execute "virsh pool-start #{new_resource.name}" do
          command "virsh pool-start #{new_resource.name}"
          not_if { active?(new_resource.name) }
          returns new_resource.returns
          action :nothing
        end.run_action(:run)
      end

      def action_autostart
        execute "virsh pool-autostart #{new_resource.name}" do
          command "virsh pool-autostart #{new_resource.name}"
          not_if { autostart?(new_resource.name) }
          returns new_resource.returns
          action :nothing
        end.run_action(:run)
      end
    end
  end
end
