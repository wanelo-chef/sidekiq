#
# Cookbook Name:: sidekiq
# Provider:: default
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

action :create do
  new_resource.updated_by_last_action(false)

  name = new_resource.name
  user = new_resource.user

  service_name = new_resource.include_prefix ? "sidekiq-#{name}" : name
  run_command = '/opt/local/bin/sidekiq.sh'

  rails_env = new_resource.rails_env || node['sidekiq']['rails_env']
  config_dir = new_resource.config_dir || node['sidekiq']['config_dir']
  pid_dir = new_resource.pid_dir || node['sidekiq']['pid_dir']
  log_dir = new_resource.log_dir || node['sidekiq']['log_dir']

  config_file = "#{config_dir}/#{name}.yml"
  log_file = "#{log_dir}/sidekiq-#{name}.log"

  environment_variables = {
      'RUBY_HEAP_MIN_SLOTS' => '500000',
      'RUBY_HEAP_SLOTS_INCREMENT' => '100000',
      'RUBY_HEAP_SLOTS_GROWTH_FACTOR' => '1',
      'RUBY_GC_MALLOC_LIMIT' => '30000000'
  }

  path = %w(/opt/local/bin /opt/local/sbin /usr/bin /usr/sbin)

  if new_resource.rvm
    path << "/home/#{user}/.rvm/bin"
    environment_variables.merge!(
        'rvm_path' => "/home/#{user}/.rvm",
        'rvm_bin_path' => "/home/#{user}/.rvm/bin",
        'rvm_prefix' => "/home/#{user}",
        'TERM' => 'xterm',
        'PATH' => path.join(':'),
        'GEM_HOME' => "/home/#{user}/.rvm/gems/#{new_resource.rvm}"
    )
  end

  directory config_dir do
    mode 0755
  end

  directory pid_dir do
    user user
    group new_resource.group
    mode 0775
  end

  directory log_dir do
    owner user
    group new_resource.group
    mode 0775
  end

  service service_name do
    supports :enable => true, :disable => true, :restart => true, :reload => true
  end

  template run_command do
    source 'wrapper.sh.erb'
    cookbook 'sidekiq'
    mode 0755
    notifies :send_notification, new_resource, :immediately
  end

  template config_file do
    source 'config.yml.erb'
    cookbook 'sidekiq'
    mode 0755
    variables 'verbose' => new_resource.verbose,
              'namespace' => new_resource.namespace,
              'concurrency' => new_resource.concurrency,
              'processes' => new_resource.processes,
              'sidekiq_timeout' => new_resource.sidekiq_timeout,
              'pid_dir' => node['sidekiq']['pid_dir'],
              'queues' => new_resource.queues
    notifies :send_notification, new_resource, :immediately
  end

  smf service_name do
    cmd = "#{run_command} -c #{config_file} -e #{rails_env} -l #{log_file} -p #{new_resource.processes}"
    cmd << " -r /home/#{user}/.rvm" if new_resource.rvm

    user user
    group new_resource.group
    project new_resource.project

    start_command cmd
    start_timeout new_resource.start_timeout
    stop_timeout new_resource.stop_timeout
    restart_timeout new_resource.restart_timeout
    working_directory "/home/#{user}/app/current"

    environment(environment_variables.merge!(new_resource.environment))
    dependencies(new_resource.dependencies)
    property_groups(
        'config' => {
            'rails_env' => rails_env,
            'config_file' => config_file,
            'log_file' => log_file
        }
    )
    notifies :send_notification, new_resource, :immediately
  end
end

action :send_notification do
  new_resource.updated_by_last_action(true)
end
