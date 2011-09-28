source 'http://rubygems.org'

gem 'rails', '3.0.9'

gem 'sqlite3'
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


group(:development, :production) do
  gem "mysql"
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
  gem "sqlite3-ruby", :require => "sqlite3"
  gem "webrat"
end

group(:test) do
  gem "ruby-debug19", :require => "ruby-debug"
end