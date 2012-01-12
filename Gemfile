source 'http://rubygems.org'

gem 'rails', '3.0.9'

gem "mysql"
gem "activeadmin"
gem "annotate"
gem "cancan"
gem "carmen"
gem "compass"
gem "devise"
gem "ezcrypto"
gem "haml-rails"
gem "hashie"
gem "heroku-rails"
gem "jquery-rails"
gem "oauth"
gem "resque"
gem "resque-scheduler"
gem "responders"
gem "sass"
gem "simple_form"
gem 'activemerchant', :require => 'active_merchant'
gem "twitter"
gem "jrails"
gem "bitly"
gem 'whenever', :require => false
gem "acts_as_soft_delete_by_field"
gem 'capistrano-ext'
gem 'mail'
gem 'exception_notification'

#gem "delayed_job",  :git => 'git://github.com/collectiveidea/delayed_job.git'
#gem 'delayed_job_active_record', :git => 'https://github.com/collectiveidea/delayed_job_active_record.git'
#gem "taps", "~> 0.3.23"
gem "fb_graph"
#gem "omniauth", "0.3"

#gem "grackle"
gem 'crack'

gem "pg"

group(:development, :production) do
  gem "mysql"
  #  gem "pg"
end


group(:test, :cucumber, :development) do
  gem "database_cleaner"
  gem "factory_girl"
  gem "factory_girl_rails"
end

group(:test, :cucumber) do
  gem "cucumber"
  gem "cucumber-rails"
  gem "faker"
  gem "launchy"
  gem "rspec"
  gem "rspec-core", :require => "rspec/core"
  gem "rspec-expectations", :require => "rspec/expectations"
  gem "rspec-mocks", :require => "rspec/mocks"
  gem "rspec-rails"
  gem "webrat"
end

group(:development) do
  gem "ruby-debug19", :require => "ruby-debug"
end