#
# ALL TIMES MUST BE STORED IN UTC BASED ON THE USER'S TimeIndex TIMEZONE PREFERENCE
#
# ALL CHANGES ON WEEKLY MUST BE PERFORMED
#
class TimeDefinition < ActiveRecord::Base

  # Constants
  DAYS_OF_WEEK = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]

  # Associations
  belongs_to :time_index
  belongs_to :buffer_preference

  #
  # Axioms:
  # 1) If my tweet_mode is weekly_basic and my dow is 0, then I need to duplicate myself across all my brothers
  #

  after_save    :update_brothers
  after_destroy :destroy_brothers


  def day
    DAYS_OF_WEEK.at(self.day_of_week)
  end

  def day=(day_sym)
    dow = DAYS_OF_WEEK.index(day_sym)
    raise "Invalid day symbol" if dow.nil?
    self.day_of_week = dow
  end

  def weekly?
    self.time_index.weekly?
  end

  def daily?
    self.time_index.daily?
  end


protected

  def update_brothers
    mode = self.time_index.tweet_mode
    return true if not self.weekly?
    return true if self.day_of_week > 0

    brothers = TimeDefinition.all(
      :conditions => {
        :buffer_preference_id => self.buffer_preference_id,
        :time_index_id        => self.time_index_id
        :day_of_week          => *(1..6)
      }
    )

    brothers.each do |timedef|
      timedef.update_attributes(
        :interval         => self.interval,
        :interval_length  => self.interval_length,
        :start_hour       => self.start_hour,
        :start_minute     => self.start_minute
      )
    end
  end

  def destroy_brothers
    mode = self.time_index.tweet_mode
    return true if not self.weekly?
    return true if self.day_of_week > 0

    brothers = TimeDefinition.all(
      :conditions => {
        :buffer_preference_id => self.buffer_preference_id,
        :time_index_id        => self.time_index_id
      }
    )

    brothers.each{|brother| brother.destroy }
  end



end
