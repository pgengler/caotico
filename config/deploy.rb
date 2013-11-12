require 'bundler/capistrano'

set :application, 'caotico'
set :deploy_to, '/srv/apps/caotico'

set :repository, 'git://github.com/pgengler/caotico.git'
set :scm, 'git'
set :branch, 'master'

set :user, 'caotico'
set :use_sudo, false
set :rvm_install_with_sudo, true
set :rails_env, 'production'
set :keep_releases, 5

server 'hyperion.pgengler.net', :app, :web, :db, primary: true

before 'deploy:finalize_update' do
  # Link shared database.yml file
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

# Restart Passenger
deploy.task :restart, roles: :app do
  run "touch #{current_path}/tmp/restart.txt"
end

namespace :db do
	task :seed do
		run "cd #{current_path}; RAILS_ENV=production bundle exec rake db:seed"
	end
end

after 'deploy', 'deploy:cleanup'

require './config/boot'
