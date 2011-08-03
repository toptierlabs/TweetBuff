class BufferPreference < ActiveRecord::Base

  belongs_to  :user
  belongs_to  :twitter_user

  has_many    :time_definitions
  has_many    :time_indices
  has_many    :tweets

  validates_uniqueness_of :name, :scope => :twitter_user_id

end
