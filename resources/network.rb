actions :define, :undefine, :destroy, :create, :autostart, :start

def initialize(*args)
  super
  @action = :create
end

# name
# uuid
