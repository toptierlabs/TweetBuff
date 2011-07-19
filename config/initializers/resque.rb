require 'resque'
require 'resque_scheduler'

resque_config = YAML.load_file(File.join(Rails.root, 'config', 'resque.yml'))
Resque.redis = Redis.new(resque_config[Rails.env].symbolize_keys)
