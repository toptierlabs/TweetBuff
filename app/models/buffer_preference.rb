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
  
  with_options :dependent => :destroy do |bp|
    bp.has_many :time_definitions
    bp.has_many :tweets
  end
  
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
  
  def retweeted_count(twitter_user)
    Twitter.configure do |config|
      config.consumer_key       = TWITTER_API[:key]
      config.consumer_secret    = TWITTER_API[:secret]
      config.oauth_token        = twitter_user.access_token
      config.oauth_token_secret = twitter_user.access_secret
    end

    client = Twitter::Client.new
    id_status = self.id_status.to_s
    feed = client.status(id_status)
    unless feed.nil?
      feed.retweet_count
    end
  end
  
  def like_feed(twitter_user)
    me = FbGraph::User.me(twitter_user.access_token)
    
    id_status = self.id_status.to_s
    feed = me.statuses.select{|s| s.identifier.eql?(id_status)}.first
    unless feed.nil?
      feed.likes.count
    end
  end
  
  def comment_feed(twitter_user)
    me = FbGraph::User.me(twitter_user.access_token)
    
    id_status = self.id_status.to_s
    feed = me.statuses.select{|s| s.identifier.eql?(id_status)}.first
    unless feed.nil?
      feed.comments.count
    end
  end
    
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
    buffers = BufferPreference.where("deleted_at IS NULL")
    time_to_check = Time.now.utc
    buffers.each do |buffer|
         
      twitter_user = buffer.twitter_user
           
      user_timezone = buffer.user.timezone
      buffer_run_at = buffer.run_at.utc 
      Time.zone = user_timezone || 'UTC'
      
      buffer_run_at_compare =  Time.utc(buffer_run_at.year, buffer_run_at.month, buffer_run_at.day, buffer_run_at.hour, buffer_run_at.min, buffer_run_at.sec)
      time_now_check = time_to_check.in_time_zone
      time_now_compare = Time.utc(time_now_check.year, time_now_check.month, time_now_check.day, time_now_check.hour, time_now_check.min, time_now_check.sec)
      if (buffer_run_at_compare - time_now_compare) <= 60
        log = "=========================\n"
        log << "posting tweet to @#{twitter_user.login} at #{Time.now.in_time_zone}\n"
        log << "=========================\n\n"
        
        file = File.open("buffer_log.txt","a+")
        file.puts(log )
        file.close
        
        if twitter_user.account_type.eql?("twitter")
          Twitter.configure do |config|
            config.consumer_key       = TWITTER_API[:key]
            config.consumer_secret    = TWITTER_API[:secret]
            config.oauth_token        = twitter_user.access_token
            config.oauth_token_secret = twitter_user.access_secret
          end
        
          client = Twitter::Client.new
          post = client.update(buffer.name)
          id_status =  post.id
        else
          me = FbGraph::User.me(twitter_user.access_token)
          feed = me.feed!(:message => buffer.name)
          id_status = feed.identifier.split("_")[1]
        end
        
        buffer.update_attributes(:status => "success", :id_status => id_status)
        buffer.soft_delete #mark as deleted_at
      end
    end
    
    #    exec("echo all job clear.")
  end

  def self.update_added_time
    buffers = BufferPreference.where(["status = ? AND deleted_at IS NULL", "uninitialized"])
    
    buffers.each do |buffer|
      buffer.added_time -= 1 if buffer.added_time > 0
      buffer.save
    end
  end

  #
  # END tweet_mode overrides
  #

  def tweet_basis
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
    buffers = BufferPreference.in_buffer_list(self.twitter_user)
    selected_days = time_setting.day_of_week.split(",")
    time_periode = time_setting.time_period.split(",")
    
    do_run_at(buffers, selected_days, time_periode)
  end

  protected
  
  def do_run_at(buffers, selected_days, time_periode)
    send_time = Time.now.utc
    start_time = send_time
    is_breaked = false
    
    buffers.each do |buffer|
      if Time.now.year % 4 
        number_of_days_in_a_year = 366
      else
        number_of_days_in_a_year = 365
      end
      
      1.upto(number_of_days_in_a_year) do |day|
        send_time = send_time + (day-1).days if is_breaked
        is_breaked = false
        
        if selected_days.include?(send_time.strftime("%u"))
          time_periode.each do |time|
            selected_time = "#{send_time.strftime("%Y")}-#{send_time.strftime("%m")}-#{send_time.strftime("%d")} #{time.split(":").first}:#{time.split(":").last}:00"
            
            stime = start_time.strftime("%Y-%m-%d %H:%M:00")
            sltdtime = selected_time.to_time.strftime("%Y-%m-%d %H:%M:00")
            if buffers.map(&:run_at).include?(selected_time.to_time) or stime > sltdtime
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
  
  def self.send_notification
    users = User.where(notify: true)
    
    users.each do |user|
      twitter_users = user.twitter_users
      twitter_users.each do |twitter_user|
        buffer_count = twitter_user.buffer_preferences.count("deleted_at IS NULL")
        
        if buffer_count < 1
          log = "=========================\n"
          log << "sending mail to @#{twitter_user.login} at #{Time.now}\n"
          log << "=========================\n\n"
          
          file = File.open("mailer_log.txt","a+")
          file.puts(log )
          file.close
          
          Notifier.buffer_run_out(user, twitter_user).deliver
        end
      end
    end
  end

end
