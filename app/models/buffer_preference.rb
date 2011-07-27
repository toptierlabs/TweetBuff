class BufferPreference < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :intervals_per_diem
  validates_presence_of :interval_duration

end
