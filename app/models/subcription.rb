class Subcription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user
  
  scope :active_subcription, lambda {|user| where("active = ? AND user_id = ?", true, user.id).limit(1)}
    
end
