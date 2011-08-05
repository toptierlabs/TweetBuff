#
# ALL TIMES MUST BE STORED IN UTC BASED ON THE USER'S TimeIndex TIMEZONE PREFERENCE
#
# ALL CHANGES ON WEEKLY MUST BE PERFORMED
#
class TimeDefinition < ActiveRecord::Base

  attr_accessor :start_at

  # Constants
  DAYS_OF_WEEK = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]

  INTERVALS = [
    ["5 minutes", 5],
    ["10 minutes", 10],
    ["15 minutes", 15],
    ["30 minutes", 30],
    ["45 minutes", 45],
    ["1 hour", 60],
    ["2 hours", 120]
  ]



  # Associations
  belongs_to :buffer_preference

  #
  # Axioms:
  # 1) If my tweet_mode is weekly_basic and my dow is 0, then I need to duplicate myself across all my brothers
  #

  after_save    :update_brothers
  after_destroy :destroy_brothers


  def self.new_time(basis, definition)
    hour    = definition[:start_at].split(":").first
    minute  = definition[:start_at].split(":").last

    case basis
    when :weekly
      TimeDefinition.create(
        :day_of_week          => 0,
        :buffer_preference_id => definition[:buffer_preference_id],
        :interval             => false,
        :interval_length      => 0,
        :start_hour           => hour,
        :start_minute         => minute
      )
    when :daily
      TimeDefinition.create(
        :day_of_week          => definition[:day_of_week],
        :buffer_preference_id => definition[:buffer_preference_id],
        :interval             => false,
        :interval_length      => 0,
        :start_hour           => hour,
        :start_minute         => minute
      )
    end
  end


  def day
    DAYS_OF_WEEK.at(self.day_of_week)
  end

  def day=(day_sym)
    dow = DAYS_OF_WEEK.index(day_sym)
    raise "Invalid day symbol" if dow.nil?
    self.day_of_week = dow
  end

  def weekly?
    self.buffer_preference.weekly?
  end

  def daily?
    self.buffer_preference.daily?
  end


protected

  def update_brothers
    mode = self.buffer_preference.tweet_mode
    return true if not self.weekly?
    return true if self.day_of_week > 0

    brothers = TimeDefinition.all(
      :conditions => {
        :buffer_preference_id => self.buffer_preference_id,
        :day_of_week          => [*(1..6)]
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
    mode = self.buffer_preference.tweet_mode
    return true if not self.weekly?
    return true if self.day_of_week > 0

    brothers = TimeDefinition.all(
      :conditions => {
        :buffer_preference_id => self.buffer_preference_id,
      }
    )

    brothers.each{|brother| brother.destroy }
  end



end
