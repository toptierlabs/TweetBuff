class Tweet < ActiveRecord::Base

  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :send_at
  
  
  # TODO position system
  
end
