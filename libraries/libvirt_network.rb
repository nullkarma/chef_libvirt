# -*- coding: utf-8 -*-
include Chef::Mixin::ShellOut

class Chef
  class Resource
    class LibvirtNetwork < Chef::Resource
      identity_attr :name
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :libvirt_network
        @provider = Chef::Provider::LibvirtNetwork
        @action = :create
        @allowed_actions = [ :define, :create, :undefine, :destroy, :autostart, :start, :noautostart, :createxml ]
        @name = name
        @returns = 0
        @uuid = nil
        @bridge_name = nil
        @forward_mode = nil
        @virtualport_type = nil
        @source = nil
        @running = false
      end
      
      def uuid(arg=nil)
        set_or_return(:uuid, arg, :kind_of => [String])
      end
      
      def forward_mode(arg=nil)
        set_or_return(:forward_mode, arg, :kind_of => [String])
      end

      def bridge_name(arg=nil)
        set_or_return(:bridge_name, arg, :kind_of => [String])
      end

      def virtualport_type(arg=nil)
        set_or_return(:virtualport_type, arg, :kind_of => [String])
      end

      def source(arg=nil)
        set_or_return(:source, arg, :kind_of => [String])
      end

    end
  end
end


class Chef
  class Provider
    class LibvirtNetwork < Chef::Provider
      # implement load_current_resource method to load previous resource before action
      def load_current_resource
        @current_resource = Chef::Resource::LibvirtNetwork.new(@new_resource.name)
        @current_resource.name(@new_resource.name)
        @current_resource.uuid(@new_resource.uuid)
        @current_resource.bridge_name(@new_resource.bridge_name)
        @current_resource.forward_mode(@new_resource.forward_mode)
        @current_resource.virtualport_type(@new_resource.virtualport_type)
        @current_resource.source(@new_resource.source)
        @current_resource
      end

      def is_exists?
        Mixlib::ShellOut.shell_out_with_systems_locale("virsh net-info #{@new_resource.name}").exitstatus == 0
      end
      
      def is_active?
        Mixlib::ShellOut.shell_out_with_systems_locale("virsh net-info #{@new_resource.name} | grep -qE '^Active:.*yes$'").exitstatus == 0
      end
      
      def is_persistent?
        Mixlib::ShellOut.shell_out_with_systems_locale("virsh net-info #{@new_resource.name} | grep -qE '^Persistent:.*yes$'").exitstatus == 0
      end

      def is_autostart?
        Mixlib::ShellOut.shell_out_with_systems_locale("virsh net-info #{@new_resource.name} | grep -qE '^Autostart:.*yes$'").exitstatus == 0
      end


      def action_createxml
        new_resource.updated_by_last_action(true)
      end

      def action_define
        cmd = Mixlib::ShellOut.new("virsh", "net-define", @new_resource.source)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def action_create
        cmd = Mixlib::ShellOut.new("virsh", "net-create", @new_resource.source)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def action_undefine
        if is_exists?
          cmd = Mixlib::ShellOut.new("virsh", "net-undefine", @new_resource.name)
          cmd.run_command
          cmd.error!
          new_resource.updated_by_last_action(true)
        end
      end

      def action_destroy
        if is_active?
          cmd = Mixlib::ShellOut.new("virsh", "net-destroy", @new_resource.name)
          cmd.run_command
          cmd.error!
          new_resource.updated_by_last_action(true)
        end
      end

      def action_autostart
        if is_exists?
          cmd = Mixlib::ShellOut.new("virsh", "net-autostart", @new_resource.name)
          cmd.run_command
          cmd.error!
          new_resource.updated_by_last_action(true)
        end
      end

      def action_start
        if is_exists?
          cmd = Mixlib::ShellOut.new("virsh", "net-start", @new_resource.name)
          cmd.run_command
          cmd.error!
          new_resource.updated_by_last_action(true)
        end
      end

      def action_noautostart
        if is_autostart?
          cmd = Mixlib::ShellOut.new("virsh", "net-autostart", "--disable", @new_resource.name)
          cmd.run_command
          cmd.error!
          new_resource.updated_by_last_action(true)
        end
      end

    end
  end
end

