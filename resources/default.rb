#
# Cookbook Name:: sidekiq
# Resource:: default
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

actions :create, :send_notification
default_action :create

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :include_prefix, :kind_of => [TrueClass, FalseClass], :default => true

attribute :user, :kind_of => [String], :required => true
attribute :group, :kind_of => [String, NilClass], :default => 'root'
attribute :project, :kind_of => [String, NilClass], :default => nil

attribute :namespace, :kind_of => String, :default => 'sq'
attribute :queues, :kind_of => Hash, :required => true

attribute :verbose, :kind_of => [TrueClass, FalseClass], :default => false
attribute :concurrency, :kind_of => Integer, :default => 1
attribute :processes, :kind_of => Integer, :default => 1

# used in SMF configuration
attribute :start_timeout, :kind_of => Integer, :default => 60
attribute :stop_timeout, :kind_of => Integer, :default => 40
attribute :restart_timeout, :kind_of => Integer, :default => 40

# used by Sidekiq itself to kill running jobs after a SIGTERM
attribute :sidekiq_timeout, :kind_of => Integer, :default => 30

attribute :rvm, :kind_of => [String, FalseClass, NilClass], :default => false
attribute :environment, :kind_of => Hash, :default => {}

attribute :dependencies, :kind_of => Array, :default => []

# optional resource
# these default to node attributes if unset
attribute :config_dir, :kind_of => [String, NilClass], :default => nil
attribute :pid_dir, :kind_of => [String, NilClass], :default => nil
attribute :log_dir, :kind_of => [String, NilClass], :default => nil
attribute :rails_env, :kind_of => [String, NilClass], :default => nil
