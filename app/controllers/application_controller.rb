class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      flash[:notice] = t("dashboard.index.welcome", :name => resource.email)
      return dashboard_path
    elsif resource.is_a?(AdminUser)
      return admin_path
    end
  end
  
  
end
