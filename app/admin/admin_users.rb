ActiveAdmin.register AdminUser do
  filter :email
  
  index do    
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    default_actions
  end
end
