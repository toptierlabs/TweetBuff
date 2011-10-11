class Api::SessionsController < ApplicationController
  protect_from_forgery :except => [:check_sign_in_session]
  
  def check_sign_in_session
    if user_signed_in?
      @status = 1
    else
      @status = 0
    end
    respond_to do |format|
      format.xml
    end
  end
 
end