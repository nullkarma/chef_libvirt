actions :define, :undefine, :destroy, :create, :autostart, :start
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :uuid, kind_of: String

def initialize(*args)
  super
  @action = :create
end

