class TweetInterval < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :user
  belongs_to :timeframe
end
