actions :define, :undefine, :destroy, :create, :autostart, :start
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :uuid, kind_of: String
attribute :target, kind_of: Array
attribute :source, kind_of: Array

def initialize(*args)
  super
  @action = :create
end

