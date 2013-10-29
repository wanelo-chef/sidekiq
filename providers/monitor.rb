action :create do
  new_resource.updated_by_last_action(false)

  template '/opt/local/bin/sidekiq-monitor.sh' do
    source 'sidekiq-monitor.sh.erb'
    cookbook 'sidekiq'
    mode 0755
    notifies :send_notification, new_resource, :immediately
  end

  smf new_resource.name do
    user new_resource.user
    group new_resource.group

    start_command "/opt/local/bin/sidekiq-monitor.sh -c %{config/config_file} -e %{config/rack_env} -r %{config/rackup_file}"
    start_timeout 60
    stop_command ':kill -9'
    stop_timeout 15
    working_directory new_resource.application_dir

    environment('TERM' => 'xterm',
                'PATH' => "#{new_resource.path_additions.join(':')}:/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin")
    property_groups(
      'config' => {
        'config_file' => "#{new_resource.application_dir}/sidekiq_monitor.ru",
        'rack_env' => new_resource.rack_env,
        'rackup_file' => "#{new_resource.application_dir}/config/unicorn/sidekiq_monitor.rb"
      }
    )

    notifies :send_notification, new_resource, :immediately
  end
end

action :send_notification do
  new_resource.updated_by_last_action(true)
end
