class AccountController < ApplicationController
  def index

  end
  
  def change_pwd
    @tempvar = current_user.to_json
    password = params[:current_pwd]
    new_pwd = params[:new_pwd]
    confirm_pwd = params[:confirm_new_pwd]
    testbool = user_signed_in?
    if !current_user.nil?
      puts 'Current user not nil'
      if new_pwd == confirm_pwd
        if(current_user.valid_password? password)
          current_user.password = new_pwd
          current_user.confirm_pwd = confirm_pwd
          current_user.save!
        end  
      end
    else
      puts 'Current nil'
    end
    
    
    render :index
    
  end
end
