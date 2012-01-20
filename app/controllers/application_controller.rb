class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_cart
    if session[:cart_id]
      @current_cart ||= Cart.find(session[:cart_id])
      @current_cart.update_attribute(:user_id, current_user.id) if user_signed_in?
      session[:cart_id] = nil if @current_cart.purchased_at
    elsif session[:cart_id].nil?
      if user_signed_in?
        @current_cart = Cart.create!(:user_id => current_user.id)
      else
        @current_cart = Cart.create!
      end
      LineItem.create(:plan_id => session[:plan_id], :cart_id => @current_cart.id, :qty => 1)
      session[:cart_id] = @current_cart.id
    end
    @current_cart
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      flash[:notice] = t("dashboard.show.welcome", :name => resource.email)
      
      twitter_user = current_user.twitter_users.first
      unless twitter_user.blank?
        if twitter_user.account_type.eql?("twitter")
          return twitter_user_path(current_user.twitter_users.first.login)
        else
          return facebook_user_path(current_user.twitter_users.first.login)
        end
      else
        return add_account_path
      end
    elsif resource.is_a?(AdminUser)
      return admin_dashboard_path
    end
  end
  
  def error_when_sign_up(resource)
    unless resource.errors.nil?
      flash[:error] = t("devise.registrations.email_blank")
    end
  end
  
  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      flash[:notice] = t("dashboard.show.welcome", :name => resource.email)
      
      twitter_user = current_user.twitter_users.first
      unless twitter_user.blank?
        return twitter_user_path(current_user.twitter_users.first.login)
      else
        return add_account_path
      end
    elsif resource.is_a?(AdminUser)
      return admin_dashboard_path
    end
  end

  def set_active_subscription
    if user_signed_in?
      subscription = Subcription.find(:all, :conditions => [""])
    end
  end
  
  def twitter_config(user)
    Twitter.configure do |config|
      config.consumer_key       = TWITTER_API[:key]
      config.consumer_secret    = TWITTER_API[:secret]
      config.oauth_token        = user.access_token
      config.oauth_token_secret = user.access_secret
    end
  end
  
  protected
  
  def facebook_config(user)
    @me = FbGraph::User.me(user.access_token)
  end
  
  def twitter_account_required
    if user_signed_in?
      if TwitterUser.find_by_user_id(current_user.id).nil?
        redirect_to add_account_path
        return
      end
    end
  end
  
  def is_max_tweet_buffer?(user)
    accounts = TwitterUser.find_all_by_user_id(current_user.id).count
    @active_plans = Subcription.active_subcription(current_user).first
  end
  
  def is_team_member
    @team_member = User.where("referal_id is NOT NULL")
  end

end
