#!/bin/sh

if [ ! -d config ]; then
    mkdir config
fi

echo "worker_processes Integer(ENV[\"WEB_CONCURRENCY\"] || 3)
timeout 15
preload_app true

# listen '/vagrant/myApp/tmp/unicorn.sock'
# pid    '/vagrant/myApp/tmp/unicorn.pid'

listen File.expand_path('tmp/unicorn.sock', ENV['RAILS_ROOT'])
pid File.expand_path('tmp/unicorn.pid', ENV['RAILS_ROOT'])

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])" > ./config/unicorn.rb


if [ ! -d lib ]; then
   mkdir lib
    if [ ! -d tasks ]; then
   	 mkdir lib/tasks
	fi
fi

echo "namespace :unicorn do

  # Tasks
  desc \"Start unicorn\"
  task(:start) {
    config = Rails.root.join('config', 'unicorn.rb')
    sh \"unicorn -c #{config} -E development -D\"
  }

  desc \"Stop unicorn\"
  task(:stop) {
    unicorn_signal :QUIT
  }

  desc \"Restart unicorn with USR2\"
  task(:restart) {
    unicorn_signal :USR2
  }

  desc \"Increment number of worker processes\"
  task(:increment) {
    unicorn_signal :TTIN
  }

  desc \"Decrement number of worker processes\"
  task(:decrement) {
    unicorn_signal :TTOU
  }

  desc \"Unicorn pstree (depends on pstree command)\"
  task(:pstree) do
    sh \"pstree '#{unicorn_pid}'\"
  end

  # Helpers
  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      path = File.expand_path('tmp/unicorn.pid', ENV['RAILS_ROOT'])
      File.read(\"#{path}\").to_i
    rescue Errno::ENOENT
      raise \"Unicorn does not seem to be running\"
    end
  end

end" > ./lib/tasks/unicorn.rake

