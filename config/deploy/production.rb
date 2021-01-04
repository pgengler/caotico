server 'hyperion.pgengler.net', user: 'pgengler-net', roles: %w{web app db}
set :rails_env, :production
set :bundle_binstubs, nil
set :rvm_ruby_version, 'ruby-2.4.4@caotico'
