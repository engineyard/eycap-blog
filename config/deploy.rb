require "bundler/capistrano"
require "capistrano-rbenv"
require "eycap/recipes"

set :rbenv_ruby_version, "2.1.2"

server "192.168.33.10", :web, :app, :db, primary: true

set :application, "eycap-blog"
set :user, "vagrant"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:engineyard/#{application}.git"
set :branch, "master"

set :default_run_options, {:pty => true}
set :ssh_options, {:forward_agent => true, keys: ['~/.vagrant.d/insecure_private_key']}

after "deploy", "deploy:cleanup" # keep only the last 5 releases

  namespace :deploy do

    task :restart, :roles => :app do
      # mongrel.restart
    end


    task :spinner, :roles => :app do
      # mongrel.start
    end


    task :start, :roles => :app do
      # mongrel.start
    end


    task :stop, :roles => :app do
      # mongrel.stop
    end

  end