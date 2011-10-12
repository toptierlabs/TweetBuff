class Api::TwitterUsersController < ApplicationController
  protect_from_forgery :except => [:twitter_account_list, :post_to_twitter, :send_to_buff]
  before_filter :authenticate_user!
  
  def twitter_account_list
    @twitter_users = current_user.twitter_users
    
    respond_to do |format|
      format.xml
    end
  end
  
  def post_to_twitter
    unless params[:tweet_message].empty?
      if params[:twitter_name].blank?
        @tweet_status = 0
        @tweet_message = "Failed : You don't have twitter account name."
      else
        user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
        unless user.blank?
          Twitter.configure do |config|
            config.consumer_key       = TWITTER_API[:key]
            config.consumer_secret    = TWITTER_API[:secret]
            config.oauth_token        = user.access_token
            config.oauth_token_secret = user.access_secret
          end
          client = Twitter::Client.new
          status = CGI.unescape(params[:tweet_message])
          url = status.match(/https?:\/\/[\S]+/)
          unless url.nil?
            bitly_api = current_user.bitly_api
            unless bitly_api.nil?
              bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
              bitly_url = bitly.shorten(url.to_s).short_url
              status = status.gsub(url.to_s,bitly_url)
            end
          end
          begin
            client.update(status)
            @tweet_status = 1
            @tweet_message = "Success : Your tweet has been posted."
          rescue
            @tweet_status = 0
            @tweet_message = "Failed : Status is a duplicate."
          end
        else
          @tweet_status = 0
          @tweet_message = "Failed : Can't find twitter account name with #{params[:twitter_name]}."
        end
      end
    else
      @tweet_status = 0
      @tweet_message = "Failed : Tweet message can't be blank."
    end
    respond_to do |format|
      format.xml
    end
  end
  
  def send_to_buff
    unless params[:tweet_message].empty?
      if params[:twitter_name].blank?
        @tweet_status = 0
        @tweet_message = "Failed : You don't have twitter account name."
      else
        twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
        if twitter_user.blank?
          @tweet_status = 0
          @tweet_message = "Failed : Can't find twitter account name with #{params[:twitter_name]}."
        else
          buffer_preference = twitter_user.buffer_preferences.create(:name => CGI.unescape(params[:tweet_message]),:status => "uninitialized")
          error_messages = buffer_preference.errors
          if error_messages.blank?
            @tweet_status = 1
            @tweet_message = "Success : Your tweet has been sent to buff."
          else
            @tweet_status = 0
            @tweet_message = "Failed : Tweet message has already been taken."
          end
        end
      end
    else
      @tweet_status = 0
      @tweet_message = "Failed : Tweet message can't be blank."
    end
    respond_to do |format|
      format.xml
    end
  end
  
  protected
  
  def update_run_at
    @ti = @twitter_user.tweet_interval
    @tf = @ti.timeframe

    if @tf
      @post_at = @tf.value.to_i
      if @tf.unit.eql?("minutes")
        run_at = Time.now + @post_at.minutes
      elsif @tf.unit.eql?("hours")
        run_at = Time.now + @post_at.hours
      end
    else
      #block to check if user use other_interval
      buffer_not_success = @twitter_user.buffer_preferences.find(:all, :conditions => ["status = ? AND run_at IS NOT NULL","uninitialized"])
      minute_hours = @ti.other_interval.split("|") # => ["10:15 PM","h.m.p"...]
      mh_count = minute_hours.count
      all_run = 0
      mark_index = 0
      year = Time.now.strftime('%Y')
      month = Time.now.strftime('%m')
      day = Time.now.strftime('%d')
      date = Time.now.strftime('%D')
      hour = Time.now.strftime('%H')
      minute = Time.now.strftime('%M')
      run_sat = nil
      # iterate all minute_hours
      unless buffer_not_success.blank?
        minute_hours.each_with_index do |minute_hour, index|
          last_run = buffer_not_success.last.run_at.strftime("%H:%M")
          if minute_hour.eql?(last_run)
            if index < (mh_count - 1)
              tes = (index+1)
            elsif index == (mh_count - 1)
              tes = 0
            end
            run_sat = minute_hours[tes.to_i]
          end
        end
      else
        run_sat = minute_hours[0]
      end
      dj_min_hour = run_sat.split(":") rescue minute_hours[0].split(":")
      last_buffer = buffer_not_success.last
      last_buffer_run = last_buffer.run_at rescue Time.now
      last_buffer_added_time = last_buffer.added_time rescue 0
      if last_buffer_run.strftime("%H:%M").eql?(minute_hours.last) || last_buffer_added_time > 0 # didieu yeuh nu salah!!!!!!
        last_run = last_buffer_run.strftime("%H:%M").eql?(minute_hours.last)? last_buffer_added_time+1 : last_buffer_added_time
        run_at = Time.utc(year,month,day,dj_min_hour[0],dj_min_hour[1]) +last_run.day
        added_time = last_buffer_added_time + 1 if run_sat.eql?(minute_hours.first)
        #debugger
      else
        run_at = Time.utc(year,month,day,dj_min_hour[0],dj_min_hour[1])
        added_time = 0
      end
    end
    #debugger
    @run_at = run_at
    @buffer_preference.update_attributes({:run_at => @run_at, :added_time => added_time})
  end
end
  