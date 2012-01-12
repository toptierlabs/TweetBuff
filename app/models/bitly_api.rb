class BitlyApi < ActiveRecord::Base
  belongs_to :user
  
  with_options {:presence => true, :uniqueness => true} do |bitly_api|
    bitly_api.validates :bitly_name
    bitly_api.validates :api_key
  end

end
