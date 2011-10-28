class Day < ActiveRecord::Base
  def self.collect_days
    days = []
    current_time = Time.now
    for i in 1..7 do      
      time_now = current_time + i.days
      days << [time_now.strftime("%A"), time_now.strftime("%Y-%m-%d")]
    end

    days
  end
end