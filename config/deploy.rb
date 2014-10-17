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
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml.example"), "#{shared_path}/config/database.yml"
    put File.read("config/secrets.yml.example"), "#{shared_path}/config/secrets.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/secrets.yml  #{release_path}/config/secrets.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
end