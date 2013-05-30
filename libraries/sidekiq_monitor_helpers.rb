module SidekiqMonitorHelpers
  def monitor_uses_rvm?
    node['sidekiq']['monitor']['use_rvm']
  end
end

Chef::Recipe.send(:include, SidekiqMonitorHelpers)
