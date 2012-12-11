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
