module TwitterAuth
  class Error < StandardError; end
  
  class Engine < Rails::Engine
  end
  
end


require 'twitter_auth/twit_lib'
require 'twitter_auth/cryptify'
require 'twitter_auth/oauth_user'
require 'twitter_auth/dispatcher/shared'
require 'twitter_auth/dispatcher/oauth'
require 'twitter_auth/dispatcher/basic'


module TwitterAuth
  module Dispatcher
    class Error < StandardError; end
    class Unauthorized < Error; end
  end
end