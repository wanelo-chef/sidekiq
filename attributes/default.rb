

default['sidekiq']['rails_env'] = 'production'
default['sidekiq']['config_dir'] = '/etc/sidekiq'
default['sidekiq']['log_dir'] = '/var/log/sidekiq'
default['sidekiq']['pid_dir'] = '/var/run/sidekiq'

default['sidekiq']['monitor']['redis']['listen_attribute'] = 'ipaddress'
default['sidekiq']['monitor']['redis']['port'] = 6379
default['sidekiq']['monitor']['redis']['db'] = 11
default['sidekiq']['monitor']['redis']['namespace'] = nil
default['sidekiq']['monitor']['user'] = 'sidekiq-monitor'
default['sidekiq']['monitor']['group'] = 'sidekiq-monitor'

default['sidekiq']['monitor']['path_additions'] = []
