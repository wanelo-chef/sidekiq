

actions :create, :send_notification
default_action :create

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :user, :kind_of => String, :required => true
attribute :group, :kind_of => [String, NilClass], :default => nil
attribute :application_dir, :kind_of => String, :required => true
attribute :path_additions, :kind_of => Array, :default => []
attribute :rack_env, :kind_of => String, :default => 'production'
