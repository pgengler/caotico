require 'bundler/capistrano'

set :application,   'caotico'
set :deploy_to,     '/srv/apps/caotico'
set :repository,    'git://github.com/pgengler/caotico.git'
set :scm,           'git'
set :branch,        'master'
set :user,          'root'
set :runner,        'www-data'
set :admin_runner,  'www-data'
set :rails_env,     'production'
set :keep_releases, 5

server 'minimoose.pgengler.net', :app, :web, :db, primary: true

before 'deploy:finalize_update' do
  # Link shared database.yml file
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

# Restart Passenger
deploy.task :restart, roles: :app do
  # Fix Permissions
  sudo "chown -R www-data:www-data #{current_path}"
  sudo "chown -R www-data:www-data #{latest_release}"
  sudo "chown -R www-data:www-data #{shared_path}/bundle"
  sudo "chown -R www-data:www-data #{shared_path}/log"

  # Restart Application
  run "touch #{current_path}/tmp/restart.txt"
end

namespace :db do
	task :seed do
		run "cd #{current_path}; RAILS_ENV=production bundle exec rake db:seed"
	end
end

after 'deploy', 'deploy:cleanup'

require './config/boot'
