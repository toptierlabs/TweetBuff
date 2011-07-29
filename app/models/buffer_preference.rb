class BufferPreference < ActiveRecord::Base

  belongs_to  :user
  belongs_to  :twitter_user

  has_many    :time_definitions
  has_many    :time_indices
  has_many    :tweets




end
