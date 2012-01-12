class Timeframe < ActiveRecord::Base
  has_and_belongs_to_many :plans
  
  with_options :dependent => :destroy do |tf|
    tf.has_many :tweet_intervals
    tf.has_many :time_setting
  end
end
