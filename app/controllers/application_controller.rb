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
      return dashboard_path
    elsif resource.is_a?(AdminUser)
      return admin_path
    end
  end


  def set_active_subscription
    if user_signed_in?
      subscription = Subcription.find(:all, :conditions => [""])
    end
  end
  
end
