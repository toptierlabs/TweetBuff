class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!

  def index
    #redirect_to twitter_user_url(session[:current_twitter_user]) unless session[:current_twitter_user].nil? redirect current url if user switch their twitter account
    if params[:twitter_name]
      @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
      @buffer_preference = @twitter_user.buffer_preferences.new
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
    @is_updated_interval = is_interval_updated?
  end

  def tweet_to_twitter
    if request.xhr?
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
            bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
            bitly_url = bitly.shorten(url.to_s).short_url
            status = status.gsub(url.to_s,bitly_url)
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
    end
  end

  def twitter_account_list
    @twitter_users = current_user.twitter_users
    render :layout => false
  end

  def update_timezone
    #puts current_user
    @timezone = current_user.update_attribute("timezone", params[:account][:timezone])
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
    @options = []
    @twitter_user = TwitterUser.find_by_login(params[:twitter_name])
    timeframe = Timeframe.all
    timeframe.each do |tf|
      @options << ["#{tf.name}","#{tf.id}"]
    end
    @options << ["other","99"]
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
    #debugger
    twitter_uid = params[:timeframe][:twitter_user_id]
    tf = params[:tfname]
    if params[:timeframe][:timeframe_id].eql?("99")
      other_time = ""
      params[:form_count].to_i.times do |i|
        #(tf[:hour][i].to_i + 12) if tf[:meridian][i].eql?("pm")
        other_time << "#{tf[:hour][i]}:#{tf[:minute][i]}|"
      end
      tweet_interval = TweetInterval.find_by_twitter_user_id(twitter_uid)
      if tweet_interval.update_attributes({:timeframe_id => nil, :other_interval => other_time.gsub("\n","")})
        redirect_to :back, :notice => "thankyou, your settings has been updated."
      end
    else
      tweet_interval = TweetInterval.find_by_twitter_user_id(twitter_uid)
      if tweet_interval.update_attributes(params[:timeframe].merge(:other_interval => nil))
        redirect_to :back, :notice => "thankyou, your settings has been updated."
      end
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