class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!

  def index
    if params[:twitter_name]
      @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
      @buffer_preference = @twitter_user.buffer_preferences.new
      @buffers = @twitter_user.buffer_preferences.oldest_order
    else
      @twitter_users = current_user.twitter_users
      @twitter_user = @twitter_users.first
      unless @twitter_user.nil?
        twitter_name = @twitter_user.login
        return redirect_to twitter_user_url(twitter_name)
        #        twitter_user = current_user.twitter_users.find_by_permalink(twitter_name)
        #        @buffer_preference = twitter_user.buffer_preferences.new
        #        @buffers = twitter_user.buffer_preferences.newest_order
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
          puts client.update(params[:tweet])
          page << "$('#post_notice').removeClass('error');"
          page << "$('#post_notice').addClass('success');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Your tweet has been posted.');"
          page << "$('#loader').hide();"
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

  def settings
    @is_updated_interval = is_interval_updated?
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
    t_uid = params[:timeframe][:twitter_user_id]
    tf = params[:tfname]
    if params[:timeframe][:timeframe_id].eql?("99")
      other_time = "#{tf[:hour]}.#{tf[:minute]}.#{tf[:meridian]}"
      tweet_interval = TweetInterval.find_by_twitter_user_id(t_uid)
      if tweet_interval.update_attributes({:timeframe_id => nil, :other_interval => other_time})
        redirect_to :back, :notice => "thankyou, your settings has been updated."
      end
    else
      tweet_interval = TweetInterval.find_by_twitter_user_id(t_uid)
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
  
end


#    tweet = TweetHistory.find(t_uid) rescue nil
#    if tweet.nil?
#      @tweet = TweetHistory.new({:twitter_user_id => t_uid, :last_tweet => Time.now, :tweet_remain => 6})
#      @tweet.save
#    else
#      @tweet = tweet.update_attributes({:twitter_user_id => t_uid, :last_tweet => Time.now, :tweet_remain => 6})
#    end