# config valid only for current version of Capistrano
lock '3.3.5'

# Define the name of the application
require 'bundler/capistrano'
set :application, 'helloworld'

# Define where can Capistrano access the source repository
# set :repo_url, 'https://github.com/[user name]/[application name].git'
set :scm, :git
set :repo_url, 'https://github.com/enestorovic/helloworld.git'
set :branch, "master"
set :shallow_clone, 1

# Define where to put your application code
set :deploy_to, "/var/www/helloworld"

set :user, "deploy" #this is the ubuntu user we created
set :password, "ebilu529" #deploy's password
set :use_sudo, false

set :mysql_user, "deploy" #this is the mysql user we created
set :mysql_password, "secret"

set :pty, true

set :format, :pretty


# namespace :deploy do
#
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 d
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end
#
# end


#Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end



after "deploy:setup", "db_yml:create"
after "deploy:update_code", "db_yml:symlink"

namespace :db_yml do
  desc "Create database.yml in shared path" 
  task :create do
    config = {
              "production" => 
              {
                "adapter" => "mysql2",
                "socket" => "/var/run/mysqld/mysqld.sock",
                "username" => mysql_user,
                "password" => mysql_password,
                "database" => "#{application}_production"
              }
            }
    put config.to_yaml, "#{shared_path}/database.yml"
  end

  desc "Make symlink for database.yml" 
  task :symlink do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml" 
  end
end