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

This recipe assumes that you are using Unicorn to run Sidekiq Monitor out
of a Ruby project directory. It requires a unicorn configuration file at
`$PROJECT_ROOT/config/unicorn/sidekiq_monitor.rb` and a rackup file at
`$PROJECT_ROOT/sidekiq_monitor.ru`.

`$PROJECT_ROOT` is set via the node attribute `node['sidekiq']['monitor']['project_root']`.

The user by which Sidekiq Monitor is run is set via the node attribute
`node['sidekiq']['monitor']['user']`.

The RACK_ENV by which Sidekiq Monitor is run is set via
`node['sidekiq']['monitor']['rack_env']`.

Ruby should be in the PATH. This can by set by adding to the array
`node['sidekiq']['monitor']['path_additions']`.
