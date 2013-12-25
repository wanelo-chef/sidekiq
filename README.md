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

Both ways use a small wrapper Rack application to run the monitoring
Sinatra app that ships with Sidekiq.

### `sidekiq::monitor` recipe

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
  path_additions ['/opt/rbenv/versions/2.0.0/bin']

  redis_host node['privateaddress']
  redis_port 6379
  redis_db 11
  redis_namespace 'sk'

  unicorn_host node['privateaddress']
  unicorn_port 8880
  rack_env 'production'

  notifies :restart, 'service[my-sidekiq-monitor]'
end
```

By default the LWRP will create a user 'sidekiq-monitor' and group
'sidekiq-monitor' to run as. It will check out a small Rack application
at `/opt/sidekiq-monitor`. Configuration files will go into
`/etc/sidekiq-monitor` and log files will go in
`/var/log/sidekiq-monitor`.
