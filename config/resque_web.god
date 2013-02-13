require 'rubygems'
require 'yaml'

rails_env   = ENV['RAILS_ENV'] || 'development'
rails_root  = ENV['RAILS_ROOT']

resque_config = YAML.load_file(rails_root.to_s + '/config/resque.yml')
redis = resque_config[rails_env] || 'localhost:6379'

app_dir     = ENV['RESQUE_WEB_APP_DIR'] || '~/.vegas/resque-web'
resque_web_port = ENV['RESQUE_WEB_PORT'] || 5678

God.watch do |w|
  w.name     = "resque-web"
  w.interval = 30.seconds

  w.dir = rails_root
  w.log = "#{rails_root}/log/#{w.name}.log"
  w.env = { 'RAILS_ROOT' => rails_root,
            'RAILS_ENV' => rails_env }

  w.start = "bundle exec resque-web --app-dir #{app_dir} -L -r #{redis} -p #{resque_web_port}"
  w.stop = "bundle exec resque-web --app-dir #{app_dir} -K"

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
