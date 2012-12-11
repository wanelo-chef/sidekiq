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
rails_env = node["sidekiq"]["rails_env"]

sidekiq_monitor_run_path    = "#{application_directory}/sidekiq_monitor.ru"
sidekiq_monitor_config_path = "#{application_directory}/config/unicorn/sidekiq_monitor.rb"

smf "sidekiq-monitor" do
  user node["sidekiq"]["monitor"]["user"]
  group node["sidekiq"]["monitor"]["group"]
  start_command "(BUNDLE_GEMFILE=#{application_directory}/Gemfile bundle exec unicorn -c #{sidekiq_monitor_config_path} -E #{rails_env} -D #{sidekiq_monitor_run_path} 2>&1)"
  start_timeout 30
  stop_timeout 15
  working_directory application_directory
end
