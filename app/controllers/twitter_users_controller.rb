class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :twitter_account_required

  def index
    #redirect_to twitter_user_url(session[:current_twitter_user]) unless session[:current_twitter_user].nil? redirect current url if user switch their twitter account
    if params[:twitter_name]
      @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
      @buffer_preference = @twitter_user.buffer_preferences.new rescue nil
      @buffers = @twitter_user.buffer_preferences.oldest_order
      session[:current_twitter_user] = params[:twitter_name]
    else
      @twitter_users = current_user.twitter_users
      @twitter_user = @twitter_users.first
      unless @twitter_user.nil?
        twitter_name = @twitter_user.login
        session[:current_twitter_user] = twitter_name
        return redirect_to twitter_user_url(twitter_name)
      end
    end
    
    @twitter_account_list = current_user.twitter_users
    @is_updated_interval = is_interval_updated?

    plans = Subcription.find_all_by_user_id(current_user.id)
    @plans = plans.last
    if @plans.plan.name.eql?("Free")
      @total_buffer = 20
    elsif @plans.plan.name.eql?("Pro")
      @total_buffer = 60
    end
    
    if @buffers.nil?
      @count_buffer = 0
    else
      @count_buffer = @buffers.count
    end
    
    @each_twitter_user = current_user.twitter_users
    @each_twitter_user.each do |account|
      @buffers_per_account = account.buffer_preferences.oldest_order
      @count_each_buffer_account = @buffers_per_account.count
    end
    
    
  end
  
  def delete_buffer
    @buffers = BufferPreference.find(params[:id])
    @buffers.destroy
    if request.xhr?
      @result_buffers = BufferPreference.find_all_by_twitter_user_id(current_user.twitter_users.first.id)
      @twitter_user = current_user.twitter_users.first.id
      render :update do |page|
        page << "$('#buffer_wrapper').append(#{render :partial => "list_buffer" })"
      end
    end
    redirect_to :back
  end
  
  def edit_buffer
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @buffer = BufferPreference.find(params[:id])
    #    render :layout => false
    respond_to do |format|
      format.js {render :edit_buffer}
    end
  end
  
  def update_buffer
    @buffer = BufferPreference.find(params[:id])
    @buffer.name = params[:buffer_preference][:name]
    @buffer.save!
    respond_to do |format|
      format.js {render :update_buffer}
    end
  end
  
  def tweet_from_buffer
    user = BufferPreference.find(params[:id]).twitter_user
    Twitter.configure do |config|
      config.consumer_key       = TWITTER_API[:key]
      config.consumer_secret    = TWITTER_API[:secret]
      config.oauth_token        = user.access_token
      config.oauth_token_secret = user.access_secret
    end
    client = Twitter::Client.new
    user_status = BufferPreference.find(params[:id])
    status = user_status.permalink
    user_status.deleted_at = Time.now
    user_status.status = "success"
    user_status.save!
    
    url = status.match(/https?:\/\/[\S]+/)
    unless url.nil?
      bitly_api = current_user.bitly_api
      unless bitly_api.nil?
        bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
        bitly_url = bitly.shorten(url.to_s).short_url
        status = status.gsub(url.to_s,bitly_url)
      end
    end
    client.update(status)
    redirect_to :back
  end
  
  def tweet_to_twitter
    if request.xhr?
      @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
      if @twitter_user.account_type.eql?("facebook")
        
      elsif @twitter_user.account_type.eql?("twitter")
        render :update do |page|
          unless params[:tweet].empty?
            user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
            Twitter.configure do |config|
              config.consumer_key       = TWITTER_API[:key]
              config.consumer_secret    = TWITTER_API[:secret]
              config.oauth_token        = user.access_token
              config.oauth_token_secret = user.access_secret
            end
            client = Twitter::Client.new
            status = params[:tweet]
            url = status.match(/https?:\/\/[\S]+/)
            unless url.nil?
              bitly_api = current_user.bitly_api
              unless bitly_api.nil?
                bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
                bitly_url = bitly.shorten(url.to_s).short_url
                status = status.gsub(url.to_s,bitly_url)
              end
            end
            client.update(status)
            page << "$('#post_notice').removeClass('error');"
            page << "$('#post_notice').addClass('success');"
            page << "$('#post_notice').show();"
            page << "$('#post_notice').html('Your tweet has been posted.');"
            page << "$('#loader').hide();"
            page << "$('#tweet_text').val('')"
            page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
          else
            page << "$('#post_notice').removeClass('success');"
            page << "$('#post_notice').addClass('error');"
            page << "$('#post_notice').show();"
            page << "$('#post_notice').html('Please fill the form.');"
            page << "$('#loader').hide();"
            page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
          end
        end
      else
        user = BufferPreference.find(params[:id]).twitter_user
        Twitter.configure do |config|
          config.consumer_key       = TWITTER_API[:key]
          config.consumer_secret    = TWITTER_API[:secret]
          config.oauth_token        = user.access_token
          config.oauth_token_secret = user.access_secret
        end
        client = Twitter::Client.new
        user_status = BufferPreference.find(params[:id])
        status = user_status.permalink
        status = params[:tweet]
        user_status.deleted_at = Time.now
        user_status.status = "success"
        user_status.save!
    
        url = status.match(/https?:\/\/[\S]+/)
        unless url.nil?
          bitly_api = current_user.bitly_api
          unless bitly_api.nil?
            bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
            bitly_url = bitly.shorten(url.to_s).short_url
            status = status.gsub(url.to_s,bitly_url)
          end
        end
        client.update(status)
        redirect_to :back
      end
    end
  end

  def twitter_account_list
    @twitter_users = current_user.twitter_users
    render :layout => false
  end

  def update_timezone
    #puts current_user
    #    @timezone = current_user.update_attribute("timezone", params[:account][:timezone])
    @timezone = current_user.update_attribute("timezone_id", params[:account][:timezone])
    redirect_to :back, :notice => "Your timezone has been updated."
  end

  def update_notify
    @timezone = current_user.update_attribute("notify", params[:account][:notify])
    notice = params[:account][:notify].eql?("1")? {:notice => "we will send you an email whenever your buffer is run out."} : {:notice => "You will not recieve notification email when your buffer is run out"}
    redirect_to :back, notice
  end

  def settings
    @is_updated_interval = is_interval_updated?
    @bitly = BitlyApi.find(current_user.id) rescue nil
    
    days = Day.all
    #    @days = days.collect {|day| [day.day_name, day.id]}
    #    @days = Day.collect_days(days)
    
    user = User.find(current_user.id)
    @myplan = user.subcriptions.last.plan
    #    @tweet_smart = myplan.num_of_tweet_per_day
    #    @tweet_smart = tweet_smarts.collect {|time| [time.value, time.id]}
    
    @options = []
    @twitter_user = TwitterUser.find_by_login(params[:twitter_name])

    user = User.find(current_user.id)
    myplan = user.subcriptions.last.plan
    @myplan_timeframes = myplan.timeframes

    timeframe = @myplan_timeframes
    timeframe.each do |tf|
      @options << ["#{tf.name}","#{tf.id}"]
    end
    
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @twitter_id = @twitter_user.id
    sent_buffers = BufferPreference.where("twitter_user_id = #{@twitter_id} AND deleted_at IS NOT NULL")
    @sent_buffers = sent_buffers.count
    plans = Subcription.find_all_by_user_id(current_user.id)
    @plans = plans.last
    if @plans.plan.name.eql?("Free")
      @total_buffer = 20
    elsif @plans.plan.name.eql?("Pro")
      @total_buffer = 60
    end
    @buffers = @twitter_user.buffer_preferences.oldest_order
    if @buffers.nil?
      @count_buffer = 0
    else
      @count_buffer = @buffers.count
    end
  end
  
  def add_an_account
    
  end
  
  def invite_team_member
    #    @team_member = User.create(:email=>params[:member][:email], :referal_id=>current_user.id, :validate=> false)
    
    @team_member = params[:member][:email]
    @referer = current_user.email
    Notifier.invite_team_member(@team_member, @referer, current_user).deliver
    
    redirect_to :back
  end

  def other_time_interval
    render :layout => false
  end

  def default_interval
    if user_sign_in?
      @twitter_user = current_user.twitter_users
    end
    render :layout => false
  end

  def save_settings
    twitter_uid = params[:timeframe][:twitter_user_id]
    tf = params[:tfname]
    if params[:timeframe][:timeframe_id].eql?("99")
      other_time = ""
      params[:form_count].to_i.times do |i|
        #(tf[:hour][i].to_i + 12) if tf[:meridian][i].eql?("pm")
        other_time << "#{tf[:hour][i]}:#{tf[:minute][i]}|"
      end
      tweet_interval = TimeSetting.find_by_twitter_user_id(twitter_uid)
      year = Time.now.strftime('%Y')
      month = Time.now.strftime('%m')
      day = Time.now.strftime('%d')
      if tweet_interval.nil?
        if params[:time_setting_type].eql?("tweet_smart")
          time_setting = 1
          day_of_week = params[:days].join(",")
          post_per_day = params[:day_time]
          unless post_per_day.nil?
            TimeSetting.create(:timeframe_id => nil, :user_id => current_user.id, :twitter_user_id => twitter_uid, :time_setting_type => time_setting, :post_per_day => post_per_day, :day_of_week => day_of_week)
          else
            redirect_to :back, :notice => "error."
          end
        elsif params[:time_setting_type].eql?("choose_tweeting_time")
          time_setting = 2
          day_of_week = params[:days].join(",")
          start_time = Time.utc(year,month,day,tf[:hour][0],tf[:minute][0])
          TimeSetting.create(:timeframe_id => nil, :start_time => start_time, :user_id => current_user.id, :twitter_user_id => twitter_uid, :time_setting_type => time_setting, :day_of_week => day_of_week)
        elsif params[:time_setting_type].eql?("custom_tweeting_time")
          time_setting = 3
          day_of_week = params[:days].join(",")
          custom_time = Time.utc(year,month,day,params[:tfname][:hour][1],params[:tfname][:minute][1])
          TimeSetting.create(:timeframe_id => params[:timeframe_id], :user_id => current_user.id, :twitter_user_id => twitter_uid, :time_setting_type => time_setting, :day_of_week => day_of_week, :custom_time => custom_time)
        end
      else
        update_day_of_week = params[:days].join(",")
        if params[:time_setting_type].eql?("tweet_smart")
          #          unless params[:day_time].nil?
          tweet_interval.update_attributes({:day_of_week => update_day_of_week, :post_per_day => params[:day_time]})
          #            redirect_to :back, :notice => "thankyou, your settings has been updated." 
          #          else
          #            redirect_to :back, :notice => "error."
          #          end
        elsif params[:time_setting_type].eql?("choose_tweeting_time")
          start_time = Time.utc(year,month,day,tf[:hour][0],tf[:minute][0])
          tweet_interval.update_attributes({:day_of_week => update_day_of_week, :start_time => start_time, :post_per_day => nil, :timeframe_id => params[:timeframe_id], :custom_time => nil})
        elsif params[:time_setting_type].eql?("custom_tweeting_time")
          custom_time = Time.utc(year,month,day,params[:tfname][:hour][1],params[:tfname][:minute][1])
          tweet_interval.update_attributes({:day_of_week => update_day_of_week, :timeframe_id => nil, :custom_time => custom_time, :post_per_day => nil})
        end
      end
      redirect_to :back, :notice => "thankyou, your settings has been updated."
    else
      tweet_interval = TweetInterval.find_by_twitter_user_id(twitter_uid)
      if tweet_interval.nil?
        TweetInterval.create(params[:timeframe].merge(:other_interval => nil))
      else
        tweet_interval.update_attributes(params[:timeframe].merge(:other_interval => nil))
      end
      redirect_to :back, :notice => "thankyou, your settings has been updated."
    end
  end
  
  def update_setting_time
    if request.xhr?
      twitter_uid = params[:tweet_id]
      user = User.find(current_user.id)
      myplan = user.subcriptions.last.plan
      
      time_tweet = params[:time_tweet]
      tweet_day = params[:per_day]
      setting = Subcription.find_by_user_id_and_active(user.id, true)
      setting.day_time_tweet = time_tweet
      setting.tweet_per_day = tweet_day
      setting.save!
      errors = setting.errors
      render :update do |page|
        if errors.empty?
          page << "$('#loader-buffer').hide();"
          page << "notification()"
        else
          #errors.full_messages.each {|error| page << "alert('#{error}')"}
        end
      end
    else
      twitter_uid = params[:tweet_id]
      user = User.find(current_user.id)
      myplan = user.subcriptions.last.plan
      
      time_tweet = params[:time_tweet]
      tweet_day = params[:per_day]
      setting = Subcription.find_by_user_id_and_active(user.id, true)
      setting.day_time_tweet = time_tweet
      setting.tweet_per_day = tweet_day
      setting.save!
    end
  end
  
  
  

  private

  def is_tweet_history_created?(twitter_id)
    
  end

  def is_interval_updated?
    twitter_user = TwitterUser.find_by_login(params[:twitter_name])
    unless twitter_user.nil?
      tweet_int = twitter_user.tweet_interval
      if tweet_int.nil?
        return "Please set up when #{twitter_user.login} tweets"
      end
    end
    nil
  end
  
  def is_team_member?
    current_user.referal_id.eql?(nil)
    #    !self.referal_id.eql?(nil)
  end

  def self.send_notification
    users = User.where(["notify = 't'"])
    users.each do |user|
      twitter_users = user.twitter_users
      twitter_users.each do |twitter_user|
        buffer_count = twitter_user.buffer_preferences.where(["deleted_at IS NULL"]).count
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