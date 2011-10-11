class Api::TwitterUsersController < ApplicationController
  protect_from_forgery :except => [:twitter_account_list]
  
  def twitter_account_list
    @twitter_users = current_user.twitter_users
    
    respond_to do |format|
      format.xml
    end
  end
end