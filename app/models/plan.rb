class Plan < ActiveRecord::Base

  has_many :subcriptions
  has_and_belongs_to_many :timeframes

end
