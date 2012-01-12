class BitlyApi < ActiveRecord::Base
  belongs_to :user
  
  validates :bitly_name, :presence => true
  validates :api_key, :presence => true
    
  validates :bitly_name, :uniqueness => true
  validates :api_key, :uniqueness => true

end
