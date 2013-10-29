Sidekiq
=======

## Description

## Requirements

## Attributes

## Usage

```ruby
sidekiq "my-queue" do
  user "deploy"
  concurrency 2
  processes 2
  queues "job-queue" => 5, "other-queue" => 1
end
```

## Sidekiq Monitor

There are two ways to deploy a Sidekiq Monitor. You can run the `sidekiq::monitor`
recipe, which will install a service named `sidekiq-monitor` configured based on
node attributes. You can also use the `sidekiq_monitor` LWRP.

Both ways assume that Sidekiq Monitor runs in a Unicorn process out of a Ruby
project directory.

A unicorn config file must be deployed at
`$PROJECT_ROOT/config/unicorn/sidekiq_monitor.rb` and a rackup file at
`$PROJECT_ROOT/sidekiq_monitor.ru`. See below for definition of $PROJECT_ROOT.

### `sidekiq::monitor` recipe

`$PROJECT_ROOT` is set via the node attribute `node['sidekiq']['monitor']['project_root']`.

The user by which Sidekiq Monitor is run is set via the node attribute
`node['sidekiq']['monitor']['user']`.

The RACK_ENV by which Sidekiq Monitor is run is set via
`node['sidekiq']['monitor']['rack_env']`.

Ruby should be in the PATH. This can by set by adding to the array
`node['sidekiq']['monitor']['path_additions']`.

### `sidekiq_monitor` LWRP

The LWRP can be used where multiple Sidekiq Monitors may be on the same
node.

```ruby
service 'my-sidekiq-monitor' do
  supports :enable => true, :disable => true, :restart => true, :reload => true
  action :nothing
end

sidekiq_monitor 'my-sidekiq-monitor' do
  user 'myuser'
  group 'staff'
  application_dir '/home/myuser/app/current'
  path_additions '/opt/rbenv/versions/2.0.0/bin'
  rack_env 'production'

  notifies :restart, 'service[my-sidekiq-monitor]'
end
```
