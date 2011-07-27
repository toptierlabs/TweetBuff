module TwitterAuth

  class Engine < Rails::Engine
  end

  class Error < StandardError; end

  module Dispatcher
    class Error < StandardError; end
    class Unauthorized < Error; end
  end
  
end

require 'twitter_auth/twit_lib'
require 'twitter_auth/cryptify'
require 'twitter_auth/oauth_user'
require 'twitter_auth/dispatcher/shared'
require 'twitter_auth/dispatcher/oauth'
require 'twitter_auth/dispatcher/basic'