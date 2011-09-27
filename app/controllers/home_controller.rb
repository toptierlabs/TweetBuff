class HomeController < ApplicationController

  before_filter :check_login
  layout "home"


  protected

  def check_login
    if user_signed_in?
      redirect_to(dashboard_path) and return false
    end
  end

end
