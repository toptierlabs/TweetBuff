class Timeframe < ActiveRecord::Base
  
  has_and_belongs_to_many :plans
  has_many :tweet_intervals
  
end
