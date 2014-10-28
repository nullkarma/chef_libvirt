# -*- coding: utf-8 -*-
include Chef::Mixin::ShellOut

class Chef
  class Resource
    # libvirt network resource
    class LibvirtNet < Chef::Resource
      identity_attr :name

      # rubocop:disable MethodLength
      def initialize(name, run_context = nil)
        super
        @resource_name = :libvirt_net
        @provider = Chef::Provider::LibvirtNet
        @action = :create
        @allowed_actions = [:define, :create, :undefine, :destroy, :autostart, :start, :noautostart]
        @name = name
        @returns = 0
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
    end
  end
end

class Chef
  class Provider
    # libvirt network provider
    class LibvirtNet < Chef::Provider
      # implement load_current_resource method to load previous resource before action
      def load_current_resource
        @current_resource = Chef::Resource::LibvirtNet.new(@new_resource.name)
        @current_resource.name(@new_resource.name)
        @current_resource.uuid(@new_resource.uuid)
        @current_resource.options(@new_resource.options)
        @current_resource.source(@new_resource.source)
        @current_resource
      end

      def exist?
        Mixlib::ShellOut.new("virsh net-info #{@new_resource.name}", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def active?
        Mixlib::ShellOut.new("virsh net-info #{@new_resource.name} | grep -qE '^Active:.*yes$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def persistent?
        Mixlib::ShellOut.new("virsh net-info #{@new_resource.name} | grep -qE '^Persistent:.*yes$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def autostart?
        Mixlib::ShellOut.new("virsh net-info #{@new_resource.name} | grep -qE '^Autostart:.*yes$'", environment: { 'LC_ALL' => nil }).run_command.exitstatus == 0
      end

      def create_xml
        new_resource.updated_by_last_action(true)
      end

      def action_define
        eecute "virsh net-define #{new_resource.source}" do
          command "virsh net-define #{new_resource.source}"
        end
        new_resource.updated_by_last_action(true)
      end

      def action_create
        execute "virsh net-create #{new_resource.source}" do
          command "virsh net-create #{new_resource.source}"
        end
        new_resource.updated_by_last_action(true)
      end

      def action_undefine
        execute "virsh net-undefine #{new_resource.name}" do
          command "virsh net-undefine #{new_resource.name}"
          only_if { new_resource.exist? }
        end
        new_resource.updated_by_last_action(true)
      end

      def action_destroy
        execute "virsh net-destroy #{new_resource.name}" do
          command "virsh net-destroy #{new_resource.name}"
          only_if { new_resource.active? }
        end
        new_resource.updated_by_last_action(true)
      end

      def action_autostart
        execute "virsh net-autostart #{new_resource.name}" do
          command "virsh net-autostart #{new_resource.name}"
          only_if { new_resource.exist? }
        end
        new_resource.updated_by_last_action(true)
      end

      def action_start
        execute "virsh net-start #{new_resource.name}" do
          command "virsh net-start #{new_resource.name}"
          only_if { new_resource.exist? }
        end
        new_resource.updated_by_last_action(true)
      end

      def action_noautostart
        execute "virsh net-autostart --disable #{new_resource.name}" do
          command "virsh net-autostart --disable #{new_resource.name}"
          only_if { new_resource.autostart? }
        end
        new_resource.updated_by_last_action(true)
      end
    end
  end
end
