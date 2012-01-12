class Suggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :twitter_user
  belongs_to :category
end
