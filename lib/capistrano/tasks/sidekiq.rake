namespace :sidekiq do
  task :restart, :roles => :app do
    run "bundle exec sidekiq -e staging -d"
  end
end
