class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def show
  end

  def account

  end

  def twitter
    @twitter_users = current_user.twitter_users
  end

  def update
    current_user.update_attributes(params[:user])
    redirect_to(request.referer)
  end

end