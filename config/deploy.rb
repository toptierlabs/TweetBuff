abort "needs capistrano 2" unless respond_to?(:namespace)

set :stages, %w(test production)
set :default_stage, "test"

require 'capistrano/ext/multistage'
require "bundler/capistrano"

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
set :application, "tbuff"
set :repository,  "git@github.com:toptierlabs/TweetBuff.git"

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
