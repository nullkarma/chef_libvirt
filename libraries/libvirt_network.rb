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
      end
      
      def uuid(arg=nil)
        set_or_return(:uuid, arg, :kind_of => [String])
      end
      
      def type(arg=nil)
        set_or_return(:type, arg, :kind_of => [String])
      end
      
      def mode(arg=nil)
        set_or_return(:mode, arg, :kind_of => [String])
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
        @current_resource.type(@new_resource.type)
        @current_resource.mode(@new_resource.mode)
        @current_resource.source(@new_resource.source)
        @current_resource
      end

      def createxml
        new_resource.updated_by_last_action(true)
      end

      def define
        cmd = Mixlib::ShellOut.new("virsh", "net-define", @new_resource.source)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def create
        cmd = Mixlib::ShellOut.new("virsh", "net-create", @new_resource.source)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def undefine
        cmd = Mixlib::ShellOut.new("virsh", "net-undefine", @new_resource.name)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def destroy
        cmd = Mixlib::ShellOut.new("virsh", "net-destroy", @new_resource.name)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def autostart
        cmd = Mixlib::ShellOut.new("virsh", "net-autostart", @new_resource.name)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def start
        cmd = Mixlib::ShellOut.new("virsh", "net-start", @new_resource.name)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

      def noautostart
        cmd = Mixlib::ShellOut.new("virsh", "net-autostart", "--disable", @new_resource.name)
        cmd.run_command
        cmd.error!
        new_resource.updated_by_last_action(true)
      end

    end
  end
end

