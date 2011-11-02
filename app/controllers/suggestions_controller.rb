class SuggestionsController < InheritedResources::Base
  def index
    @suggestions = Suggestion.all
    @twitter_user = params[:twitter_name]
    
    render :layout => false
  end

  def tweet_suggestion    
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @buffer_preference = @twitter_user.buffer_preferences.create(params[:buffer_preferences].merge(:status => "uninitialized"))
    errors = @buffer_preference.errors
    update_run_at

    render :update do |page|
      if errors.empty?
        page.insert_html :bottom, :buffer_wrapper, :partial => "buffer_preferences/new_buffer", :locals => {:buffer => @buffer_preference}
        page << "$('#loader-buffer').hide();"
        page << "$('#tweet_text').val('')"
        page << "notification()"
      else
        #errors.full_messages.each {|error| page << "alert('#{error}')"}
      end
    end   
    
  end

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
      if last_buffer_added_time.nil?
        a = 0
      else
        a = last_buffer_added_time
      end
      if last_buffer_run.strftime("%H:%M").eql?(minute_hours.last) || a > 0  # didieu yeuh nu salah!!!!!!
        last_run = last_buffer_run.strftime("%H:%M").eql?(minute_hours.last)? last_buffer_added_time+1 : last_buffer_added_time
        run_at = Time.utc(year,month,day,dj_min_hour[0],dj_min_hour[1]) +last_run.day
        added_time = last_buffer_added_time + 1 if run_sat.eql?(minute_hours.first)
      else
        run_at = Time.utc(year,month,day,dj_min_hour[0],dj_min_hour[1])
        added_time = 0
      end
    end
    @run_at = run_at
    @buffer_preference.update_attributes({:run_at => @run_at, :added_time => added_time})
  end

end