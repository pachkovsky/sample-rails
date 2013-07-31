set :application, "set your application name here"
set :repository,  "set your repository location here"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

server 'ec2-54-218-181-183.us-west-2.compute.amazonaws.com', :app, :web, :db, :primary => true

after "deploy:restart", "deploy:cleanup"
set :user, 'ubuntu'
set :use_sudo, false

set :application, 'sample-rails'

set :scm, :git
set :repository, "git@github.com:pavelpachkovskij/sample-rails.git"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :ssh_options, { forward_agent: true }
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end