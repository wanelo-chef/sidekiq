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

user = node["sidekiq"]["monitor"]["user"]
application_directory = "/home/#{user}/app/current"
shared_directory = "/home/#{user}/app/shared"
rails_env = node["sidekiq"]["rails_env"]

rvm_path = "/home/#{user}/.rvm"
rvm_version = node["sidekiq"]["monitor"]["rvm"]

sidekiq_monitor_run_path = "#{application_directory}/sidekiq_monitor.ru"
sidekiq_monitor_config_path = "#{application_directory}/config/unicorn/sidekiq_monitor.rb"
sidekiq_monitor_log_path = "#{shared_directory}/log/sidekiq_monitor.stderr.log"

run_command = "/opt/local/bin/sidekiq-monitor.sh"

environment_variables = {
    "rvm_path" => "/home/#{user}/.rvm",
    "rvm_bin_path" => "/home/#{user}/.rvm/bin",
    "rvm_prefix" => "/home/#{user}",
    "TERM" => "xterm",
    "PATH" => "/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin:/home/#{user}/.rvm/bin",
    "GEM_HOME" => "/home/#{user}/.rvm/gems/#{rvm_version}"
}

template run_command do
  source "sidekiq-monitor.sh.erb"
  cookbook "sidekiq"
  mode 0755
end

smf "sidekiq-monitor" do
  cmd = "#{run_command} -c #{sidekiq_monitor_config_path} -e #{rails_env} -r #{sidekiq_monitor_run_path} -R #{rvm_path}"

  user user
  group node["sidekiq"]["monitor"]["group"]

  start_command cmd
  start_timeout 60

  stop_timeout 15
  working_directory application_directory

  environment(environment_variables)
  property_groups(
      "config" => {
          "rails_env" => rails_env,
          "config_file" => sidekiq_monitor_config_path,
          "log_file" => sidekiq_monitor_log_path
      }
  )
end
