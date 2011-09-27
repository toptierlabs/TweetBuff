class PlansController < InheritedResources::Base
  #before_filter :authenticate_admin_user!, :except => [:index,:show]
  before_filter :myplan, :only => [:index,:show]

  def myplan
    if user_signed_in?
      u = User.find(current_user.id)
      @myplan = u.subcription.plan.id rescue 0
    else
      @myplan = 0
    end
  end
  
end
