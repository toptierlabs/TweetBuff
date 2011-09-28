class ApplicationController < ActionController::Base
  
  protect_from_forgery

  def current_cart
    if session[:cart_id]
      @current_cart ||= Cart.find(session[:cart_id])
      session[:cart_id] = nil if @current_cart.purchased_at
    elsif session[:cart_id].nil?
      @current_cart = Cart.create!(:user_id => current_user.id)
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
