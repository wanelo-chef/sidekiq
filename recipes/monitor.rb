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

service 'sidekiq-monitor' do
  supports :enable => true, :disable => true, :restart => true, :reload => true
  action :nothing
end

sidekiq_monitor 'sidekiq-monitor' do
  user node['sidekiq']['monitor']['user']
  group node['sidekiq']['monitor']['group']
  application_dir node['sidekiq']['monitor']['project_root']
  path_additions node['sidekiq']['monitor']['path_additions'].to_a
  rack_env node['sidekiq']['monitor']['rack_env']

  notifies :restart, 'service[sidekiq-monitor]'
end
