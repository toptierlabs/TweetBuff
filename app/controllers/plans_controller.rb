class PlansController < InheritedResources::Base
  before_filter :authenticate_admin_user!, :except => [:index,:show]
  before_filter :myplan

  def myplan
    u = User.find(current_user.id)
    @myplan = u.subcription.plan.id
  end
end
