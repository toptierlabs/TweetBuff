class ApplicationController < ActionController::Base
  
  protect_from_forgery
  #  before_filter :mailer_set_url_options
  before_filter :mailer_set_url_options
 
  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

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
      # return dashboard_path
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
  
  protected
  
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
    #    @team_member = User.where("referal_id is NOT NULL and referal_id = ?", current_user.id).first
  end

end
