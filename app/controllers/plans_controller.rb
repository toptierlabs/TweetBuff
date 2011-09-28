class PlansController < InheritedResources::Base
  #before_filter :authenticate_admin_user!, :except => [:index,:show]
  before_filter :myplan, :only => [:index,:show]

  def myplan
    if user_signed_in?
      u = User.find(current_user.id)
      @myplan = u.subcriptions.last.plan.id rescue 0
    else
      @myplan = 0
    end
  end

  def get_plan_clicked_when_signup
    session[:plan_id] = params[:id]
    @cart = current_cart
    if user_signed_in?
      redirect_to @cart.paypal_url(twitter_users_url, payment_notifications_url)
    else
      redirect_to new_user_registration_path
    end
  end
  
end
