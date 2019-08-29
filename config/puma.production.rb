require 'etc'

workers Etc.nprocessors
# puma defines here the min and max threads to use in the thread pool
# as we are using MRI, we can improve the number of supporting long running queries
# increasing the max number of threads here.
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 6)
threads threads_count, threads_count

app_dir = File.expand_path("../..", __FILE__)

rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# TODO
# Put nginx in front of rails
# bind "unix://#{app_dir}/tmp/vulcan-persistence.sock"
port ENV.fetch("PORT") { 3000 }

stdout_redirect "/var/log/vulcan-persistence/app.stdout.log", "/var/log/vulcan-persistence/app.stderr.log", true

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
