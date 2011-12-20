abort "needs capistrano 2" unless respond_to?(:namespace)

set :stages, %w(production)
set :default_stage, "production"

require 'capistrano/ext/multistage'
require "bundler/capistrano"

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
set :application, "tweetbuf"
set :repository,  "git@github.com:syafik41studio/tbuff.git"

set :directory_path, "/opt/rails_apps/#{application}"

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :scm, :git

set :use_sudo, false
set :branch, "master"
set :deploy_via, :checkout
set :git_shallow_clone, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
