#
# Cookbook Name:: sidekiq
# Recipe:: monitor
#
# Copyright 2012, Wanelo, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

application_directory = node['sidekiq']['monitor']['project_root']
path_additions = node['sidekiq']['monitor']['path_additions'].to_a

sidekiq_monitor_rackup_file = "#{application_directory}/sidekiq_monitor.ru"
sidekiq_monitor_config_file = "#{application_directory}/config/unicorn/sidekiq_monitor.rb"

run_command = '/opt/local/bin/sidekiq-monitor.sh'

environment_variables = {
    'TERM' => 'xterm',
    'PATH' => "#{path_additions.join(':')}:/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin"
}

service 'sidekiq-monitor' do
  supports :enable => true, :disable => true, :restart => true, :reload => true
  action :nothing
end

template '/opt/local/bin/sidekiq-monitor.sh' do
  source 'sidekiq-monitor.sh.erb'
  cookbook 'sidekiq'
  mode 0755
  notifies :restart, 'service[sidekiq-monitor]'
end

smf 'sidekiq-monitor' do
  user node['sidekiq']['monitor']['user']
  group node['sidekiq']['monitor']['group']

  start_command "/opt/local/bin/sidekiq-monitor.sh -c %{config/config_file} -e %{config/rack_env} -r %{config/rackup_file}"
  start_timeout 60

  stop_timeout 15
  working_directory application_directory

  environment(environment_variables)
  property_groups(
      'config' => {
          'config_file' => sidekiq_monitor_config_file,
          'rack_env' => node['sidekiq']['monitor']['rack_env'],
          'rackup_file' => sidekiq_monitor_rackup_file
      }
  )

  notifies :restart, 'service[sidekiq-monitor]'
end
