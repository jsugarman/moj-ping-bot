workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['SINATRA_MAX_THREADS'] || 3)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 9292
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  # ActiveRecord::Base.establish_connection
end