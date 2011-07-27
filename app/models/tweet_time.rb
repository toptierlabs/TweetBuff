class TweetTime < ActiveRecord::Base

  belongs_to :buffer_preference

  validates_presence_of :tweet_at

end
