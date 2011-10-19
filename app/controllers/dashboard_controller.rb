class DashboardController < ApplicationController
  
  before_filter :authenticate_user!
  
  before_filter :twitter_account_required, :except => :add_account

  def show
  end

  def account
    @user = current_user
  end

  def paypall_callback
    session[:plan_id] = nil
    session[:cart_id] = nil
    redirect_to twitter_users_path
  end

  def twitter
    @twitter_users = current_user.twitter_users
  end

  def update
    #current_user.update_attributes(params[:user])
    #redirect_to(request.referer)
    @user = current_user

    if @user.update_with_password(params[:user])
      sign_in(@user, :bypass => true)
      redirect_to dashboard_url, :notice => "Password updated!"
    else
      redirect_to :back, :notice => "Invalid current password"
    end
  end
  
  def add_account
    
  end

end