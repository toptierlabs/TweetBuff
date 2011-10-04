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

class BufferPreference < ActiveRecord::Base

  # Constants
  TWEET_MODES = [:weekly_basic, :weekly_expert, :daily_basic, :daily_expert]

  # Associations
  belongs_to  :user
  belongs_to  :twitter_user
  has_many    :time_definitions
  has_many    :tweets

  # Validations
  validates_uniqueness_of :name, :scope => :twitter_user_id
  validates_presence_of :tweet_mode

  # Callbacks
  before_validation :set_defaults
  after_create      :create_time_definitions
  before_update     :detect_tweet_mode_change
  before_save       :update_permalink
  scope :oldest_order, :order => "created_at ASC"

  # Class Methods


  # Instance Methods

  #
  # BEGIN tweet_mode overrides
  # so we can use human-readable names for modes
  #

  def tweet_mode
    mode = read_attribute(:tweet_mode)
    if mode.nil?
      mode = 0
      self.tweet_mode = :weekly_basic
    end
    TWEET_MODES.at(mode)
  end

  def tweet_mode=(mode)
    mode = mode.to_sym if mode.is_a?(String)
    idx = TWEET_MODES.index(mode)
    raise "Invalid mode" if idx.nil?
    write_attribute(:tweet_mode, idx)
  end

  def post_tweet
    
  end

  #
  # END tweet_mode overrides
  #

  def tweet_basis
    # :weekly_basic => "weekly_basic" => ["weekly","basic"] => "weekly" => :weekly
    self.tweet_mode.to_s.split("_").first.to_sym
  end

  def tweet_basis=(basis)
    raise "Invalid basis" if ![:weekly,:daily].include?(basis.to_sym)
    self.change_tweet_mode("#{basis.to_s}_#{self.tweet_mode.to_s.split("_").last}")
  end


  def weekly?
    [:weekly_basic, :weekly_expert].include?(self.tweet_mode)
  end

  def daily?
    [:daily_basic, :daily_expert].include?(self.tweet_mode)
  end

  def time_list

  end

  def to_param
    self.name
  end

protected

  def set_defaults
    self.tweet_mode ||= :weekly_basic
    self.timezone   ||= "UTC"
    self.user_id    ||= self.twitter_user.user_id
  end

  def create_time_definitions
    case self.tweet_mode
    when :weekly_basic, :daily_basic
      0.upto(6) do |dow|
        TimeDefinition.create(
          :day_of_week          => dow,
          :buffer_preference_id => self.id,
          :interval             => true,
          :interval_length      => 3600
        )
      end
    when :weekly_expert, :daily_expert
      0.upto(6) do |dow|
        TimeDefinition.create(
          :day_of_week          => dow,
          :buffer_preference_id => self.id,
          :interval             => false,
          :interval_length      => 0,
          :start_hour           => 0,
          :start_minute         => 0
        )
      end
    end
  end


  def detect_tweet_mode_change
    if(self.tweet_mode_changed?)
      ActiveRecord::Base.connection.execute("DELETE FROM time_definitions WHERE buffer_preference_id=#{self.id}")
      create_time_definitions
    end
  end


  def update_permalink
    self.permalink = self.to_param
  end

end
