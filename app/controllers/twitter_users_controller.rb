class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!

  def index
    @twitter_users = current_user.twitter_users
    unless @twitter_users.empty?
      twitter_name = @twitter_users.first.login
      twitter_user = current_user.twitter_users.find_by_permalink(twitter_name)
      @buffer_preference = twitter_user.buffer_preferences.new
      user = User.find(current_user.id)
      @buffers = user.buffer_preferences.all
    end
  end
  
end