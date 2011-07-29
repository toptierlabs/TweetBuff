# Tweet Mode
#
# Weekly Basic => No Daily Selection. Interval timing, start at time HH:MM
# Weekly Expert => No Daily Selection. Set all possible tweet times.
# Daily Basic => Set up for each day. Interval timing, start at time HH:MM
# Daily Expert => Set up for each day. Set all possible tweet times.
#
# Weekly Basic mode will automatically create SEVEN time_definitions
#   one for each day of the week, all with the same interval and start time.
#
# Weekly Expert mode will create SEVEN DUPLICATE time_definitions for each time defined,
#   one for each day of the week.
# Daily Basic -- Same as basic, but each of the SEVEN time_definitions is customizable
# Daily Expert -- Same as expert, but each time_definition is customizable

class TimeIndex < ActiveRecord::Base

  # Constants
  TWEET_MODES = [:weekly_basic, :weekly_expert, :daily_basic, :daily_expert]

  # Associations
  belongs_to :twitter_user
  belongs_to :buffer_preference

  # Validations
  validates_presence_of :tweet_mode

  # Callbacks
  after_create :create_time_defintions

  # Class Methods

  # Instance Methods

  #
  # BEGIN tweet_mode overrides
  # so we can use human-readable names for modes
  #

  def tweet_mode
    mode = read_attribute(:tweet_mode)
    TWEET_MODES.at(mode)
  end

  def tweet_mode=(mode)
    idx = TWEET_MODES.index(mode)
    raise "Invalid mode" if idx.nil?
    write_attribute(:tweet_mode, idx)
  end

  #
  # END tweet_mode overrides
  #


  def weekly?
    [:weekly_basic, :weekly_expert].include?(self.tweet_mode)
  end

  def daily?
    [:daily_basic, :daily_expert].include?(self.tweet_mode)
  end

protected


  def create_time_defintions
    case self.tweet_mode
    when :weekly_basic, :daily_basic
      0.upto(6) do |dow|
        TimeDefinition.create(
          :day_of_week => dow,
          :time_index_id => self.id,
          :buffer_preference_id => self.buffer_preference_id,
          :interval => true,
          :interval_length => 3600
        )
      end
    when :weekly_expert, :daily_expert
      0.upto(6) do |dow|
        TimeDefinition.create(
          :day_of_week => dow,
          :time_index_id => self.id,
          :buffer_preference_id => self.buffer_preference_id,
          :interval => false,
          :interval_length => 0,
          :start_hour => 0,
          :start_minute => 0
        )
      end
    end
  end


end
