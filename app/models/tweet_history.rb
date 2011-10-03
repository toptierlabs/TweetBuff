class TweetHistory < ActiveRecord::Base
  belongs_to :twitter_user
end
