class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!


  def index
    @twitter_users = current_user.twitter_users
  end


end