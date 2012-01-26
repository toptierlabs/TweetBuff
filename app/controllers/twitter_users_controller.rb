class TwitterUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :twitter_account_required
  before_filter :dashboard_account, :only => [:index, :performance, :analytic]

  def index
    @ordered_buffers = BufferPreference.where("status = ? AND twitter_user_id =?", "uninitialized", @twitter_user.id).order("run_at ASC")
    @active_time = @ordered_buffers.first.run_at.to_date rescue Date.today
    
    if request.xhr?
      render :update do |page|
        page.replace_html "buffer_wrapper", :partial => "queue", :locals => {:ordered_buffers => @ordered_buffers, :active_time => @active_time}
        page << "jQuery('#loader-tab').hide();jQuery('#buffer_wrapper').show();"
        page << "jQuery('#queue').addClass('qpa');jQuery('#performance').removeClass('performance');jQuery('#analytic').removeClass('analytic');"
        page << "jQuery('#queue').addClass('queue');"
      end
    end
  end
  
  def performance
    twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @twitter_name = twitter_user
    
    @buffers = BufferPreference.where("twitter_user_id = ? AND status = ?", twitter_user.id, "success")
        
    if twitter_user.account_type.eql?("facebook")
      @reached = twitter_user.friends_count
    elsif twitter_user.account_type.eql?("twitter")
      @reached = twitter_user.followers_count
    end
    
    @buffer_success = BufferPreference.where("twitter_user_id = ? AND status = ? ", twitter_user.id, "success").order("deleted_at ASC")
    if request.xhr?
      render :update do |page|
        page.replace_html "buffer_wrapper", :partial => "performance", :locals => {:twitter_user => @twitter_user}
        page << "jQuery('#loader-tab').hide();jQuery('#buffer_wrapper').show();"
        page << "jQuery('#performance').addClass('qpa');jQuery('#queue').removeClass('all');jQuery('#analytic').removeClass('analytic');jQuery('#queue').removeClass('queue');"
        page << "jQuery('#performance').addClass('performance');"
      end
    end
  end
  
  def analytic
    user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    facebook_config(user)
    if request.xhr?
      render :update do |page|
        page.replace_html "buffer_wrapper", :partial => "analytic", :locals => {:twitter_user => @twitter_user}
        page << "jQuery('#loader-tab').hide();jQuery('#buffer_wrapper').show();"
        page << "jQuery('#analytic').addClass('qpa');jQuery('#queue').removeClass('all');jQuery('#performance').removeClass('performance');jQuery('#queue').removeClass('queue')"
        page << "jQuery('#analytic').addClass('analytic');"
      end
    end
  end
  
  def delete_buffer
    buffer_to_delete = BufferPreference.find(params[:id])
    buffer_to_delete.destroy
    redirect_to :back, :notice => "Your buffer has successfully deleted from queue."
  end
  
  def edit_buffer
    @buffer = BufferPreference.find(params[:id])
    @twitter_user = @buffer.twitter_user
        
    respond_to do |format|
      format.js {render :edit_buffer}
    end
  end
  
  def update_buffer
    if request.xhr?
      @buffer = BufferPreference.find(params[:id])
      @buffer.name = params[:buffer_preference][:name]
      @buffer.save!
      
      @twitter_user = current_user.twitter_users.find(@buffer.twitter_user_id)
      @buffer_preference = @twitter_user.buffer_preferences.new rescue nil
      render :update do |page|
        ordered_buffers = BufferPreference.where("status = ? AND twitter_user_id =?", "uninitialized", @twitter_user.id).order("run_at ASC")
        active_time = ordered_buffers.first.run_at.to_date rescue Date.today
        
        page.replace_html 'buffer_wrapper', :partial => "buffer_preferences/new_buffer", :locals => {:ordered_buffers => ordered_buffers, :active_time => active_time}
        page.replace_html 'tweet_buffer', :partial => "buffer_preferences/new_form_buffer", :locals => {:twitter_user => @twitter_user}
        page << "$('#loader-update-buffer').hide();"
        page << "$('#tweet_text').val('')"
        page << "$('#post_notice').removeClass('error');"
        page << "$('#post_notice').addClass('success');"
        page << "$('#post_notice').show();"
        page << "$('#post_notice').html('Your tweet has successfully updated.');"
        page << "setTimeout('$(\"#post_notice\").fadeOut(200)',5000)"
      end
    end
  end
  
  def tweet_from_buffer
    user = BufferPreference.find(params[:id]).twitter_user

    if user.account_type.eql?("facebook")
      facebook_config(user)
      
      user_status = BufferPreference.find(params[:id])
      feed = @me.feed!(:message => user_status.name)
      user_status.id_status = feed.identifier.split("_")[1]
      user_status.deleted_at = Time.now
      user_status.status = "success"
      user_status.save!
      redirect_to :back, :notice => "Buffer has been posted to your facebook."
    elsif user.account_type.eql?("twitter")
      twitter_config(user)
      
      client = Twitter::Client.new
      user_status = BufferPreference.find(params[:id])
      status = user_status.permalink
      user_status.deleted_at = Time.now
      user_status.status = "success"
      
      url = status.match(/https?:\/\/[\S]+/)
      unless url.nil?
        bitly_api = current_user.bitly_api
        unless bitly_api.nil?
          user = bitly_api.bitly_name
          apikey = bitly_api.api_key
          version = "3"
          bitly_url = "http://api.bit.ly/shorten?version=#{version}&longUrl=#{url}&login=#{user}&apiKey=#{apikey}"
                
          buffer = open(bitly_url, "UserAgent" => "Ruby-ExpandLink").read
          result = JSON.parse(buffer)
          short_url = result['results'][url.to_s]['shortUrl']
          status = status.gsub(url.to_s, short_url)
        end
      end
      post_to_twitter = client.update(status)
      user_status.id_status = post_to_twitter.id
      user_status.save!
      
      redirect_to :back, :notice => "Buffer has successfully tweeted to your twitter."
    end
  end
  
  def tweet_to_twitter
    if request.xhr?
      @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
      
      tweet = params[:tweet]
      
      if @twitter_user.account_type.eql?("facebook")
        render :update do |page|
          unless tweet.empty?
            user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
            
            me = FbGraph::User.me(user.access_token)
            post_to_facebook = me.feed!(:message => tweet)
            id_status = post_to_facebook.identifier.split("_")[1]

            save_buffer = @twitter_user.buffer_preferences.new(:user_id => current_user.id, :twitter_user_id => @twitter_user.id, :name => tweet, :timezone => "UTC", :permalink => tweet, :status => "success", :deleted_at => Time.now, :id_status => id_status)
            save_buffer.save!
            
            page << "$('#post_notice').removeClass('error');"
            page << "$('#post_notice').addClass('success');"
            page << "$('#post_notice').show();"
            page << "$('#post_notice').html('Your tweet has successfully posted to your facebook.');"
            page << "$('#loader').hide();"
            page << "$('#tweet_text').val('')"
            page << "setTimeout('$(\"#post_notice\").fadeOut(200)',5000)"
          else
            page << "$('#post_notice').removeClass('success');"
            page << "$('#post_notice').addClass('error');"
            page << "$('#post_notice').show();"
            page << "$('#post_notice').html('Please fill the form.');"
            page << "$('#loader').hide();"
            page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
          end
        end
      elsif @twitter_user.account_type.eql?("twitter")
        render :update do |page|
          unless tweet.empty?
            user = current_user.twitter_users.find_by_permalink(params[:twitter_name])

            Twitter.configure do |config|
              config.consumer_key       = TWITTER_API[:key]
              config.consumer_secret    = TWITTER_API[:secret]
              config.oauth_token        = user.access_token
              config.oauth_token_secret = user.access_secret
            end
            
            client = Twitter::Client.new
            status = tweet
            url = status.match(/https?:\/\/[\S]+/)

            unless url.nil?
              bitly_api = current_user.bitly_api
              unless bitly_api.nil?
                user = bitly_api.bitly_name
                apikey = bitly_api.api_key
                version = "3"
                bitly_url = "http://api.bit.ly/shorten?version=#{version}&longUrl=#{url}&login=#{user}&apiKey=#{apikey}"
                
                buffer = open(bitly_url, "UserAgent" => "Ruby-ExpandLink").read
                result = JSON.parse(buffer)
                short_url = result['results'][url.to_s]['shortUrl']
                status = status.gsub(url.to_s, short_url)
              end
            end
            
            post_to_twitter = client.update(status)
            id_status = post_to_twitter.id

            save_buffer = @twitter_user.buffer_preferences.new(:user_id => current_user.id, :twitter_user_id => @twitter_user.id, :name => tweet, :timezone => "UTC", :permalink => tweet, :status => "success", :deleted_at => Time.now, :id_status => id_status)
            save_buffer.save!
            
            page << "$('#post_notice').removeClass('error');"
            page << "$('#post_notice').addClass('success');"
            page << "$('#post_notice').show();"
            page << "$('#post_notice').html('Your tweet has successfully tweeted to your twitter.');"
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
  end
  
  def twitter_account_list
    @twitter_users = current_user.twitter_users
    render :layout => false
  end

  def update_timezone
    Time.zone = params[:account][:timezone]
    timezone = Time.zone.to_s.split(") ").last
    @timezone = current_user.update_attribute("timezone", timezone)
    
    redirect_to :back, :notice => "Your timezone has been updated."
  end

  def update_notify
    @timezone = current_user.update_attribute("notify", params[:account][:notify])

    notice = if params[:account][:notify].eql?("1")
      {:notice => "we will send you an email whenever your buffer is run out."}
    else
      {:notice => "You will not recieve notification email when your buffer is run out"}
    end
    
    redirect_to :back, notice
  end

  def settings
    @is_updated_interval = is_interval_updated?
    @bitly = BitlyApi.find_by_user_id(current_user.id)
    
    user = User.find(current_user.id)
    @myplan = user.subcriptions.last.plan
    
    @options = []
    @twitter_user = TwitterUser.where(login: params[:twitter_name]).first
    
    user = User.find(current_user.id)
    myplan = user.subcriptions.last.plan
    @myplan_timeframes = myplan.timeframes

    timeframe = @myplan_timeframes
    timeframe.each do |tf|
      @options << ["#{tf.name}","#{tf.id}"]
    end
    
    @twitter_user = current_user.twitter_users.where(permalink: params[:twitter_name]).first
    @twitter_id = @twitter_user.id
    
    @sent_buffers_count = BufferPreference.where("twitter_user_id = #{@twitter_id} AND deleted_at IS NOT NULL").count
    
    @plans = Subcription.where(user_id: current_user.id).last
    @total_buffer = myplan.num_of_tweet_in_buffer
    
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
    @team_member = params[:member][:email]
    @referer = current_user.email
    email_regex = /^.*@.*(.com|.org|.net)$/
    
    if params[:member][:email] === email_regex
      redirect_to :back
      flash[:error] = "Please enter a valid email address."
    else
      Notifier.invite_team_member(@team_member, @referer, current_user).deliver
      redirect_to :back, :notice => "Your invitation has been send to team member."
    end
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
        other_time << "#{tf[:hour][i]}:#{tf[:minute][i]}|"
      end
      
      tweet_interval = TimeSetting.find_by_twitter_user_id(twitter_uid)
      year = Time.now.strftime('%Y')
      month = Time.now.strftime('%m')
      day = Time.now.strftime('%d')
      
      if tweet_interval.nil?
        day_of_week = params[:days].join(",")
        post_per_day = params[:day_time]
        
        if params[:time_setting_type].eql?("1")
          time_setting = 1
          time_periode = []
          
          params[:day_time].to_i.times do
            rand_hour = rand(24)
            random_hour =  rand_hour < 9 ? "0#{rand_hour}":"#{rand_hour}"
            rand_minute = rand(60)
            random_minute =  rand_minute < 9 ? "0#{rand_minute}":"#{rand_minute}"
            time_periode << "#{random_hour}:#{random_minute}"
          end
          
          sort_time_periode = time_periode.sort {|x, y| x <=> y}
          custom_time_saved = sort_time_periode.join(",")
          TimeSetting.create(:timeframe_id => nil, :user_id => current_user.id, :twitter_user_id => twitter_uid, 
            :time_period => custom_time_saved, :time_setting_type => params[:time_setting_type], :post_per_day => post_per_day, 
            :day_of_week => day_of_week)
          
        elsif params[:time_setting_type].eql?("2")
          pm = ((params[:start_at][:hour]).to_i + 12).to_s
          am = params[:start_at][:hour]
          minute = params[:start_at][:minute]
          timeframe = Timeframe.find(params[:timeframe_id])
          
          if params[:start_at][:meridian].eql?("pm")
            start_time = Time.utc(year,month,day,pm,minute)
          elsif params[:start_at][:meridian].eql?("am")
            start_time = Time.utc(year,month,day,am,minute)
          end
          
          datetimes = []
          0.upto ((24/timeframe.value)-1) do |i|
            datetimes << (start_time + (i*timeframe.value).hours).strftime('%H:%M')
          end
          
          time_period = datetimes.join(",")
          
          TimeSetting.create(:timeframe_id => params[:timeframe_id], :start_time => start_time, :user_id => current_user.id, 
            :twitter_user_id => twitter_uid, :time_setting_type => params[:time_setting_type], :day_of_week => day_of_week, 
            :time_period => time_period)
        
        elsif params[:time_setting_type].eql?("3")
          if params[:tfname][:hour][1].nil?
            custom_time = Time.new(year, month, day, params[:tfname][:hour].join(""), params[:tfname][:minute].join(""))
            many_custom_time = []
            
            params[:new_form_count].to_i.times do |parameter|
              if params[:tfname][:meridian][parameter].eql?("pm")
                if params[:tfname][:hour][parameter].eql?("12")
                  pm = (params[:tfname][:hour][parameter].to_i - 12).to_s
                  many_custom_time << "#{pm}:#{params[:tfname][:minute][parameter]}"
                else
                  pm = (params[:tfname][:hour][parameter].to_i + 12).to_s
                  many_custom_time << "#{pm}:#{params[:tfname][:minute][parameter]}"                  
                end
              elsif params[:tfname][:meridian][parameter].eql?("am")
                am = (params[:tfname][:hour][parameter]).to_s
                many_custom_time << "#{am}:#{params[:tfname][:minute][parameter]}"
              end
            end
            
            sort_time_periode = many_custom_time.sort {|x, y| x <=> y}
            custom_time_saved = sort_time_periode.join(",")

            TimeSetting.create(:timeframe_id => params[:timeframe_id], :user_id => current_user.id, 
              :twitter_user_id => twitter_uid, :time_setting_type => params[:time_setting_type], 
              :day_of_week => day_of_week, :custom_time => custom_time, :time_period => custom_time_saved)
          else
            custom_times = []
            
            params[:new_form_count].to_i.times do |i|
              if params[:tfname][:meridian][i].eql?("pm")
                pm = (params[:tfname][:hour][i].to_i + 12).to_s
                custom_times << "#{pm}:#{params[:tfname][:minute][i]}"
              elsif params[:tfname][:meridian][i].eql?("am")
                am = (params[:tfname][:hour][i]).to_s
                custom_times << "#{am}:#{params[:tfname][:minute][i]}"
              end
            end
            
            sorted_time_periode = custom_times.sort{|x, y| x <=> y}
            custom_time_saved = sorted_time_periode.join(",")
            TimeSetting.create(:timeframe_id => params[:timeframe_id], :user_id => current_user.id, :twitter_user_id => twitter_uid, 
              :time_setting_type => params[:time_setting_type], :day_of_week => day_of_week, :custom_time => custom_time, 
              :time_period => custom_time_saved)
          end
        end
      else
        update_day_of_week = params[:days].join(",")
        
        if params[:time_setting_type].eql?("1")
          time_periode = []
          
          params[:day_time].to_i.times do
            rand_hour = rand(24)
            random_hour =  rand_hour < 9 ? "0#{rand_hour}":"#{rand_hour}"
            rand_minute = rand(60)
            random_minute =  rand_minute < 9 ? "0#{rand_minute}":"#{rand_minute}"
            time_periode << "#{random_hour}:#{random_minute}"
          end
          
          sort_time_periode = time_periode.sort {|x, y| x <=> y}
          custom_time_saved = sort_time_periode.join(",")
          tweet_interval.update_attributes({:time_setting_type => params[:time_setting_type], :day_of_week => update_day_of_week, 
              :time_period => custom_time_saved, :post_per_day => params[:day_time], :timeframe_id => nil, :start_time => nil})
          
        elsif params[:time_setting_type].eql?("2")
          pm = ((params[:start_at][:hour]).to_i + 12).to_s
          am = params[:start_at][:hour]
          minute = params[:start_at][:minute]
          timeframe = Timeframe.find(params[:timeframe_id])
          
          if params[:start_at][:meridian].eql?("pm")
            start_time = Time.utc(year,month,day,pm,minute)
          elsif params[:start_at][:meridian].eql?("am")
            start_time = Time.utc(year,month,day,am,minute)
          end
          
          x = []
          0.upto ((24/timeframe.value)-1) do |i|
            x << (start_time + (i*timeframe.value).hours).strftime('%H:%M')
          end
          
          ax = x.join(",")
          tweet_interval.update_attributes({:time_setting_type => params[:time_setting_type], :day_of_week => update_day_of_week,
              :start_time => start_time, :post_per_day => nil, :timeframe_id => params[:timeframe_id], :custom_time => nil,
              :time_period => ax})
          
        elsif params[:time_setting_type].eql?("3")
          if params[:tfname][:hour][1].nil?
            custom_time = Time.utc(year,month,day,params[:tfname][:hour].join(""),params[:tfname][:minute].join(""),nil, "+00:00")
            tweet_interval.update_attributes({:time_setting_type => params[:time_setting_type], :day_of_week => update_day_of_week, :timeframe_id => nil, :custom_time => custom_time, :post_per_day => nil})
          else
            many_custom_time = []
            
            params[:new_form_count].to_i.times do |parameter|
              if params[:tfname][:meridian][parameter].eql?("pm")
                if params[:tfname][:hour][parameter].eql?("12")
                  pm = (params[:tfname][:hour][parameter].to_i - 12).to_s
                  many_custom_time << "#{pm}:#{params[:tfname][:minute][parameter]}"
                else
                  pm = (params[:tfname][:hour][parameter].to_i + 12).to_s
                  many_custom_time << "#{pm}:#{params[:tfname][:minute][parameter]}"                  
                end
              elsif params[:tfname][:meridian][parameter].eql?("am")
                am = (params[:tfname][:hour][parameter]).to_s
                many_custom_time << "#{am}:#{params[:tfname][:minute][parameter]}"
              end
            end
            
            sort_time_periode = many_custom_time.sort {|x, y| x <=> y}
            custom_time_saved = sort_time_periode.join(",")

            tweet_interval.update_attributes({:time_setting_type => params[:time_setting_type], :day_of_week => update_day_of_week, :timeframe_id => nil, :time_period => custom_time_saved, :custom_time => nil, :post_per_day => nil})
          end
        end
      end
      
      redirect_to :back, :notice => "Congratulation, your settings has been updated."
    else
      tweet_interval = TweetInterval.find_by_twitter_user_id(twitter_uid)
      
      if tweet_interval.nil?
        TweetInterval.create(params[:timeframe].merge(:other_interval => nil))
      else
        tweet_interval.update_attributes(params[:timeframe].merge(:other_interval => nil))
      end
      
      redirect_to :back, :notice => "Congratulation, your settings has been updated."
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
  
  def dashboard_account
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
  
  def is_tweet_history_created?(twitter_id)
  end

  def is_interval_updated?
    twitter_user = TwitterUser.find_by_login(params[:twitter_name])
    
    unless twitter_user.nil?
      tweet_int = twitter_user.time_setting
      if tweet_int.nil?
        return "Please set up when #{twitter_user.login} tweets"
      end
    end
    
    nil
  end
  
  def is_team_member?
    current_user.referal_id.nil?
  end
  
end