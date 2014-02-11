actions :create, :send_notification
default_action :create

attribute :ruby_server, :kind_of => String, :equal_to => ['unicorn', 'puma'], :default => 'unicorn'

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :user, :kind_of => String, :default => 'sidekiq-monitor'
attribute :group, :kind_of => [String, NilClass], :default => nil
attribute :sidekiq_monitor_dir, :kind_of => String, :default => '/opt/sidekiq-monitor'
attribute :path_additions, :kind_of => Array, :default => []
attribute :rack_env, :kind_of => String, :default => 'production'
attribute :environment, :kind_of => Hash, :default => {}

attribute :redis_host, :kind_of => String, :required => true
attribute :redis_port, :kind_of => Integer, :default => 6379
attribute :redis_db, :kind_of => Integer, :default => 11
attribute :redis_namespace, :kind_of => [String, NilClass], :default => nil

attribute :unicorn_host, :kind_of => String, :default => '0.0.0.0'
attribute :unicorn_port, :kind_of => Integer, :default => 8080
