require "bundler/capistrano"

def config(variable, description)
  value = exists?(variable) ? fetch(variable) : nil
  if value.to_s.empty? and $stdout.isatty
    print description, ": "
    value = $stdin.gets.strip
  end

  raise "#{description} not provided" if value.to_s.empty?
  set variable, value
end

config :deploy_server, "Deploy to Server"
config :deploy_user, "User Name"
config :deploy_env, "RAILS_ENV"
config :deploy_port, "HTTP Port"

set :application, "RapidFTR"
set :deploy_dir, "/srv/rapid_ftr_#{deploy_env}"

server deploy_server, :web, :app, :db
default_run_options[:pty] = $stdout.isatty
set :user, deploy_user
set :deploy_to, deploy_dir

set :scm, :git
set :repository,  "git://github.com/rapidftr/RapidFTR.git"
set :deploy_via, :remote_cache
set :branch, fetch(:branch, "master")
#to deploy a specific revision to any environment use
#RAILS_ENV=<env_name> cap -S branch=<commit-sha> deploy
#If you want to deploy the latest master use the command
#RAILS_ENV=<env_name> cap deploy

load 'config/recipes/base'
load 'config/recipes/deploy'
load 'config/recipes/db'
load 'config/recipes/sunspot'

before 'deploy:update_code', 'deploy:create_release_dir'
after  'deploy:update', 'deploy:setup_application', 'deploy:setup_nginx', 'db:migrate', 'sunspot:clean_start', 'deploy:restart'

#use RAILS_ENV=<env> cap deploy:pending and cap deploy:pending:diff to find out the diff between the master and the
#current deployed revision in the server.
