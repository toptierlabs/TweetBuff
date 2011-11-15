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

  acts_as_soft_delete_by_field
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
  after_create      :update_run_at_new, :create_time_definitions
  before_update     :detect_tweet_mode_change
  before_save       :update_permalink
  
  scope :oldest_order, :order => "created_at ASC, run_at ASC", :conditions => ["deleted_at IS NULL"]
  scope :in_buffer_list, lambda{|twitter_user|
    where("twitter_user_id = ? AND status = ?", twitter_user.id, "uninitialized")
  }

  # Class Methods


  # Instance Methods

  #
  # BEGIN tweet_mode overrides
  # so we can use human-readable names for modes
  
    
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

  def self.post_tweet
    buffers = BufferPreference.all(:conditions => ["run_at < ? AND deleted_at IS NULL", Time.now])
    buffers.each do |buffer|
      tweeted = buffer.twitter_user.buffer_preferences.all(:conditions => ["deleted_at BETWEEN ? AND ?",Time.now.beginning_of_day, Time.now.end_of_day]).count
      twitter_user = buffer.twitter_user
      plan_count = twitter_user.user.subcriptions.where(["active = 't'"]).first.plan.num_of_tweet_per_day
      if tweeted < plan_count
        log = "=========================\n"
        log << "posting tweet to @#{twitter_user.login} at #{Time.now}\n"
        log << "=========================\n\n"
        file = File.open("buffer_log.txt","a+")
        file.puts(log )
        file.close
        Twitter.configure do |config|
          config.consumer_key       = TWITTER_API[:key]
          config.consumer_secret    = TWITTER_API[:secret]
          config.oauth_token        = twitter_user.access_token
          config.oauth_token_secret = twitter_user.access_secret
        end
        client = Twitter::Client.new
        client.update(buffer.name)
        buffer.update_attribute(:status, "success")
        buffer.soft_delete #mark deleted_at
      end
      
    end
    exec("echo all job clear.")
  end

  def self.update_added_time
    buffers = BufferPreference.all(:conditions => ["status = ? AND deleted_at IS NULL","uninitialized"])
    buffers.each do |buffer|
      buffer.added_time -= 1 if buffer.added_time > 0
      buffer.save
    end
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
  
  def update_run_at_new
    time_setting = self.twitter_user.time_setting
    active_plans = Subcription.active_subcription(self.user).first
    max = active_plans.plan.num_of_tweet_in_buffer
    
    buffers = BufferPreference.in_buffer_list(self.twitter_user)
    selected_days = time_setting.day_of_week.split(",")
    
    days = ["1","2","3","4","5","6","7"]
    
        
    time_now = Time.now
    current_time = Time.new(time_now.year,time_now.month,time_now.day,time_now.hour,time_now.min,time_now.sec, "+00:00")
    
    time_periode = time_setting.time_period.split(",")
    
    must_sent_time = nil
    dj_min_hour = time_periode.first.split(":")
    must_sent_time = Time.new(current_time.year,current_time.month,current_time.day,dj_min_hour[0],dj_min_hour[1],nil, "+00:00")
    parameter = 0
    
    do_run_at(buffers, selected_days, time_periode)
  end

  protected
  
  def do_run_at(buffers, selected_days, time_periode)
    send_time = Time.now
    start_time = send_time
    is_breaked = false
    buffers.each do |buffer|
      1.upto 365 do |day|
        send_time = send_time+(day-1).days if is_breaked
        is_breaked = false
        if selected_days.include?(send_time.strftime("%u"))
          time_periode.each do |time|
            selected_time = "#{send_time.strftime("%Y")}-#{send_time.strftime("%m")}-#{send_time.strftime("%d")} #{time.split(":").first}:#{time.split(":").last}:00"
            if buffers.map(&:run_at).include?(selected_time.to_time) or start_time.strftime("%Y-%m-%d %H:%M:00") > selected_time.to_time.strftime("%Y-%m-%d %H:%M:00")
              is_breaked = true if time_periode.index(time).eql?(time_periode.length-1)
              next 
            else
              buffer.update_attribute(:run_at, selected_time)
              is_breaked = true
              break
            end
          end
        else
          send_time = send_time + 1.days
        end
        break if !buffer.run_at.eql?(nil)
      end
    end
    
  end
  
  def aduh(must_sent_time, buffers, buffer, tme, selected_days)
    1.upto(360) do |tested|
      must_sent_time1 = must_sent_time + tested.days
      must_sent_time1 = (Time.new(must_sent_time1.year,must_sent_time1.month,must_sent_time1.day,tme.split(":")[0],tme.split(":")[1],nil, "+00:00"))
      if selected_days.include?(must_sent_time1.strftime("%u")) 
        if buffers.map(&:run_at).include?(must_sent_time1)
          puts "asf"
          next
        else
          puts "2-- -------- #{tme}----#{must_sent_time1}"
          buffer.update_attributes({:run_at => must_sent_time1}) if buffer.run_at.nil?
          return buffer
        end
      else
        puts "#{tested}----#{must_sent_time}-----#{must_sent_time1}"
      end
                  
    end
  end

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
