require "bundler"
Bundler.setup(:default, :deployment)

# deploy recipes - need to do `sudo gem install thunder_punch` - these should be required last
require 'thunder_punch'

#############################################################
# Set Basics
#############################################################
set :application, "my_fr2"
set :user, "deploy"
set :current_path, "/var/www/apps/#{application}"

if File.exists?(File.join(ENV["HOME"], ".ssh", "fr_staging"))
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "fr_staging")]
else
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
end

# use these settings for making AMIs with thunderpunch
# set :user, "ubuntu"
#ssh_options[:keys] = [File.join('~/Documents/AWS/FR2', "gpoEC2.pem")]


ssh_options[:paranoid] = false
set :use_sudo, true
default_run_options[:pty] = true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }


set :finalize_deploy, false
# we don't need this because we have an asset server
# and we also use varnish as a cache server. Thus 
# normalizing timestamps is detrimental.
set :normalize_asset_timestamps, false


set :migrate_target, :current


#############################################################
# General Settings  
#############################################################

set :deploy_to,  "/var/www/apps/#{application}" 

#############################################################
# Set Up for Production Environment
#############################################################

task :production do
  set :rails_env,  "production"
  set :branch, 'production'
  
  set :gateway, 'federalregister.gov'
  
  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "my-fr2-server-1.fr2.ec2.internal", "my-fr2-server-2.fr2.ec2.internal", "my-fr2-server-3.fr2.ec2.internal", "my-fr2-server-4.fr2.ec2.internal", "my-fr2-server-5.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true} #monster image

  # Database Settings
  set :remote_db_name, "#{application}_#{rails_env}"
  set :db_path,        "#{current_path}/db"
  set :sql_file_path,  "#{current_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"
end


#############################################################
# Set Up for Staging Environment
#############################################################

task :staging do
  set :rails_env,  "staging" 
  set :branch, `git branch`.match(/\* (.*)/)[1]
  set :gateway, 'fr2.criticaljuncture.org'
  
  role :proxy,  "proxy.fr2.ec2.internal"
  role :app,    "my-fr2-server-1.fr2.ec2.internal"
  role :db,     "database.fr2.ec2.internal", {:primary => true}
  role :sphinx, "sphinx.fr2.ec2.internal"
  role :worker, "worker.fr2.ec2.internal", {:primary => true}

  # Database Settings
  set :remote_db_name, "#{application}_#{rails_env}"
  set :db_path,        "#{current_path}/db"
  set :sql_file_path,  "#{current_path}/db/#{remote_db_name}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.sql"
end


#############################################################
# SCM Settings
#############################################################
set :scm,              :git          
set :github_user_repo, 'criticaljuncture'
set :github_project_repo, 'my_fr2'
set :deploy_via,       :remote_cache
set :repository, "git@github.com:#{github_user_repo}/#{github_project_repo}.git"
set :github_username, 'criticaljuncture' 


#############################################################
# Git
#############################################################

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :git_enable_submodules, true


#############################################################
# Bundler
#############################################################
# this should list all groups in your Gemfile (except default)
set :gem_file_groups, [:deployment, :development, :test]


#############################################################
# Run Order
#############################################################

# Do not change below unless you know what you are doing!
# all deployment changes that affect app servers also must 
# be put in the user-scripts files on s3!!!

after "deploy:update_code",      "deploy:set_rake_path"
after "deploy:set_rake_path",    "bundler:fix_bundle"
after "bundler:fix_bundle",      "deploy:migrate"
after "deploy:migrate",          "assets:precompile"
after "assets:precompile",       "passenger:restart"
after "passenger:restart",       "varnish:clear_cache"


#############################################################
#                                                           #
#                                                           #
#                         Recipes                           #
#                                                           #
#                                                           #
#############################################################

namespace :apache do
  desc "Restart Apache Servers"
  task :restart, :roles => [:app] do
    sudo '/etc/init.d/apache2 restart'
  end
end

namespace :my_fr2 do
  desc "Update api keys"
  task :update_api_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:api_keys.yml #{current_path}/config/api_keys.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update secret keys"
  task :update_secret_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:my_fr2_secrets.yml #{current_path}/config/secrets.yml"
    find_and_execute_task("apache:restart")
  end
  
  desc "Update sendgrid keys"
  task :update_sendgrid_keys, :roles => [:app, :worker] do
    run "/usr/local/s3sync/s3cmd.rb get config.internal.federalregister.gov:sendgrid.yml #{current_path}/config/sendgrid.yml"
    find_and_execute_task("apache:restart")
  end
end

namespace :assets do
  task :precompile, :roles => [:app, :worker] do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end


#############################################################
# Airbrake Tasks
#############################################################

namespace :airbrake do
  task :notify_deploy, :roles => [:worker] do
    run "cd #{current_path} && bundle exec rake airbrake:deploy RAILS_ENV=#{rails_env} TO=#{branch} USER=#{`git config --global github.user`} REVISION=#{real_revision} REPO=#{repository}" 
  end
end
