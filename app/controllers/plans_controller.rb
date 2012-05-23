class PlansController < InheritedResources::Base
  before_filter :myplan, :only => [:index,:show]

  def myplan
    if user_signed_in?
      user = User.find(current_user.id)
      @myplan = user.subcriptions.last.plan.id rescue 0
    else
      @myplan = 0
    end
  end

  def get_plan_clicked_when_signup
    session[:plan_id] = params[:id]
    
    if user_signed_in?
      @cart = current_cart
      redirect_to @cart.paypal_url(twitter_users_url, payment_notifications_url)
    else
      redirect_to new_user_session_path
    end
  end
  
end
