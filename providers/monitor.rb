action :create do
  new_resource.updated_by_last_action(false)

  name = new_resource.name

  if new_resource.group
    group new_resource.group
  end

  user new_resource.user do
    gid new_resource.group if new_resource.group
  end

  %w(/var/log/sidekiq-monitor /var/run/sidekiq-monitor /etc/sidekiq-monitor).each do |dir|
    directory dir do
      recursive true
      owner new_resource.user
      group new_resource.group
      mode 0755
    end
  end

  git new_resource.sidekiq_monitor_dir do
    repository 'https://github.com/wanelo/sidekiq-monitor'

    notifies :send_notification, new_resource, :immediately
  end

  execute "chown sidekiq monitor dir #{new_resource.sidekiq_monitor_dir}" do
    command "chown -R #{new_resource.user} #{new_resource.sidekiq_monitor_dir}"
  end

  execute 'bundle install sidekiq-monitor' do
    command "bundle install --path #{new_resource.sidekiq_monitor_dir}/.bundle"
    cwd new_resource.sidekiq_monitor_dir
    user new_resource.user
    environment({
      'PATH' => "#{new_resource.path_additions.join(':')}:/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin"
    }.merge(new_resource.environment))
  end

  template '/opt/local/bin/sidekiq_monitor_runtime_dependencies' do
    source 'sidekiq-monitor/sidekiq_monitor_runtime_dependencies.erb'
    cookbook 'sidekiq'
    mode 0755
    variables 'user' => node['sidekiq']['monitor']['user'],
      'group' => node['sidekiq']['monitor']['group']
  end

  smf 'sidekiq-monitor-dependencies' do
    fmri '/application/setup/sidekiq-monitor-dependencies'
    start_command '/opt/local/bin/sidekiq_monitor_runtime_dependencies'
    stop_command 'true'
    duration 'transient'
    manifest_type 'setup'
    dependencies [
        { 'name' => 'multi-user', 'fmris' => ['svc:/milestone/multi-user'],
          'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service' }
      ]
    notifies :enable, 'service[sidekiq-monitor-dependencies]', :immediately
  end

  service 'sidekiq-monitor-dependencies' do
    supports enable: true, disable: true, reload: true
  end

  template "/etc/sidekiq-monitor/#{name}.yml" do
    source 'sidekiq-monitor/config.yml.erb'
    cookbook 'sidekiq'
    owner new_resource.user
    group new_resource.group
    variables 'host' => new_resource.redis_host,
      'port' => new_resource.redis_port,
      'db' => new_resource.redis_db,
      'namespace' => new_resource.redis_namespace

    notifies :send_notification, new_resource, :immediately
  end

  smf new_resource.name do
    user new_resource.user
    group new_resource.group

    case new_resource.ruby_server
      when 'unicorn'
        start_command 'bundle exec unicorn -o %{config/host} -p %{config/port} -E %{config/rack_env} -c %{config/unicorn_config} -D %{config/rackup_file}'
      when 'puma'
        start_command 'bundle exec puma --config %{config/puma_config} --bind tcp://%{config/host}:%{config/port} --daemon %{config/rackup_file}'
    end
    start_timeout 60
    stop_command ':kill -9'
    stop_timeout 15
    working_directory new_resource.sidekiq_monitor_dir

    environment({'TERM' => 'xterm',
      'PATH' => "#{new_resource.path_additions.join(':')}:/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin",
      'CONFIG_YML' => "/etc/sidekiq-monitor/#{name}.yml",
      'STDERR_FILE_NAME' => "#{name}.stderr.log",
      'STDOUT_FILE_NAME' => "#{name}.stdout.log",
      'PID_FILE_NAME' => "#{name}.pid",
      'LANG' => 'en_US.UTF-8',
      'LC_ALL' => 'en_US.UTF-8'}.merge(new_resource.environment))

    property_groups(
      'config' => {
        'unicorn_config' => "#{new_resource.sidekiq_monitor_dir}/config/unicorn.rb",
        'puma_config' => "#{new_resource.sidekiq_monitor_dir}/config/puma.rb",
        'rack_env' => new_resource.rack_env,
        'rackup_file' => "#{new_resource.sidekiq_monitor_dir}/config.ru",
        'host' => new_resource.unicorn_host,
        'port' => new_resource.unicorn_port
      }
    )

    dependencies [
        { 'name' => 'sidekiq-monitor-dependencies', 'fmris' => ['svc:/application/setup/sidekiq-monitor-dependencies'],
          'grouping' => 'require_all', 'restart_on' => 'none', 'type' => 'service' }
      ]

    notifies :send_notification, new_resource, :immediately
  end
end

action :send_notification do
  new_resource.updated_by_last_action(true)
end
