rails_env   = ENV['RAILS_ENV']
rails_root  = ENV['RAILS_ROOT']
workers_count = ENV['RESQUE_WORKERS_COUNT'] || 1

workers_count.times do |num|
  God.watch do |w|
    w.name     = "resque-#{num}"
    w.group    = 'resque'
    w.interval = 30.seconds
    # w.pid_file = is not set
    w.dir = rails_root
    w.log = "#{rails_root}/log/#{w.name}.log"
    w.env = { 'RAILS_ROOT' => rails_root,
              'RAILS_ENV' => rails_env,
              'QUEUE' => '*' }

    w.start = "bundle exec rake environment resque:worker"
  end

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