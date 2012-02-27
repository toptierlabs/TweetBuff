set :rails_env, "production"
set :user, "root"
set :password, "hTV4hY1e54"
set :runner, "nobody"

set :deploy_to, "#{directory_path}/#{stage}"

# =============================================================================
# ROLES
# =============================================================================
role :web, "69.25.136.103"
role :app, "69.25.136.103"
role :db,  "69.25.136.103", :primary => true

# =============================================================================
# TASKS
# =============================================================================
namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "export RAILS_ENV=production"
    
    run "rm -rf #{current_path}/log"
    run "rm -rf #{current_path}/public/system"
    run "rm -rf #{current_path}/config/database.yml"
    
    run "ln -s #{directory_path}/#{stage}/shared/log #{current_path}/log"
    run "ln -s #{directory_path}/#{stage}/shared/config/database.yml #{current_path}/config/database.yml"
    run "ln -s #{directory_path}/#{stage}/shared/system #{current_path}/public/system"
    
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
