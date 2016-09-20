#############################################################
# RVM Setup
#############################################################
set :rvm_ruby_string, '1.9.3-p551'
set :rvm_require_role, :rvm
set :rvm_type, :system
require "rvm/capistrano/selector_mixed"


#############################################################
# Set Basics
#############################################################
set :application, "federalregister-web"
set :user, "deploy"
set :current_path, "/var/www/apps/#{application}"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end


#############################################################
# General Settings
#############################################################

set :deploy_to,  "/var/www/apps/#{application}"
set :rake, "bundle exec rake"


#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'officialness'

  set :gateway, 'fr2_production'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "web-1.fr2.ec2.internal", "web-2.fr2.ec2.internal", "web-3.fr2.ec2.internal", "web-4.fr2.ec2.internal", "web-5.fr2.ec2.internal"
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  role :rvm, "web-1.fr2.ec2.internal", "web-2.fr2.ec2.internal", "web-3.fr2.ec2.internal", "web-4.fr2.ec2.internal", "web-5.fr2.ec2.internal", "sphinx.fr2.ec2.internal", "worker.fr2.ec2.internal", "proxy.fr2.ec2.internal"

  #set :github_user_repo, 'usnationalarchives'
  set :github_user_repo, 'criticaljuncture'
  set :github_project_repo, 'federalregister-web'
  #set :github_username, 'usnationalarchives'
  set :github_username, 'criticaljuncture'
  set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env, "staging"
  set :branch, `git branch`.match(/\* (.*)/)[1]

  set :gateway, 'fr2_staging'

  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "web-1.fr2.ec2.internal"
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  role :rvm, "web-1.fr2.ec2.internal", "sphinx.fr2.ec2.internal", "worker.fr2.ec2.internal", "proxy.fr2.ec2.internal"

  set :github_user_repo, 'criticaljuncture'
  set :github_project_repo, 'federalregister-web'
  set :github_username, 'criticaljuncture'
  set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
end


#############################################################
# SCM Settings
#############################################################
set :scm,              :git
set :deploy_via,       :remote_cache


#############################################################
# Bundler
#############################################################
set :gem_file_groups, [:deployment, :development, :test]


#############################################################
# Honeybadger
#############################################################

set :honeybadger_user, `git config --global github.user`.chomp


#############################################################
# Recipe role setup
#############################################################

set :deploy_roles, [:app, :worker]
set :bundler_roles, [:app, :worker]
set :db_migration_roles, [:worker]
set :asset_roles, [:app, :worker]
set :varnish_roles, [:proxy]
set :honeybadger_roles, [:worker]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!
after "deploy:update_code",     "bundler:bundle"
after "bundler:bundle",         "deploy:migrate"
after "deploy:migrate",         "assets:precompile"
after "assets:precompile",      "passenger:restart"
after "passenger:restart",      "resque:restart_workers"
after "resque:restart_workers", "varnish:clear_cache"
after "varnish:clear_cache",    "honeybadger:notify_deploy"


#############################################################
#                                                           #
#                                                           #
#                       Custom Recipes                      #
#                                                           #
#                                                           #
#############################################################

#############################################################
# Varnish Tasks (Instead of Thunderpunch)
#############################################################

namespace :varnish do
  task :clear_cache, :roles => [:worker] do
    run "cd #{current_path} && cd ../federalregister-api-core && RAILS_ENV=#{rails_env} bundle exec rake varnish:expire:everything"
  end
end

#############################################################
# Restart resque workers
#############################################################

namespace :resque do
  task :restart_workers, :roles => [:worker] do
    sudo "monit -g resque_workers_web restart"
  end
end


# deploy recipes - these should be required last
require 'thunder_punch'
require 'thunder_punch/recipes/apache'
require 'thunder_punch/recipes/honeybadger'
require 'thunder_punch/recipes/passenger'
require 'thunder_punch/recipes/assets'
