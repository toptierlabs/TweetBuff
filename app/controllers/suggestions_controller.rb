class SuggestionsController < InheritedResources::Base
  before_filter :list_suggestions, :only => [:index, :setting_suggestion]
  
  def index
    categories = Category.all
    @categories = categories.collect {|category| [category.name_of_category, category.id]}
    
    render :layout => false
  end
  
  def setting_suggestion
    categories = Category.all
    @categories = categories.collect {|category| [category.name_of_category, category.id]} + [["Create New Category", 0]]
        
    render :layout => false
  end
  
  def get_category
    @suggests = Suggestion.where(category_id: params[:file_type])
    
    render :update do |page|
      page.replace_html "selected_suggestion", :partial => "select_file_type", :locals => {:suggest => @suggests}
      page << "$('#category-loader').hide();"
      page << "$('#file_type').show();"
      page << "$('#selected_suggestion').show();"
    end
  end
  
  def create
    if request.xhr?
      new_category = params[:category]
      suggest_category = params[:suggestion][:category_id]
      
      if suggest_category.eql?("")
        @suggestion = Suggestion.create(:text => params["suggestion"]["text"], :category_id => new_category, :user_id => params["suggestion"]["user_id"], :twitter_user_id => params["suggestion"]["twitter_user_id"])
      elsif !suggest_category.nil?
        @category = Category.create(:name_of_category => suggest_category)
        @suggestion = Suggestion.create(:text => params["suggestion"]["text"], :category_id => @category.id, :user_id => params["suggestion"]["user_id"], :twitter_user_id => params["suggestion"]["twitter_user_id"])
      end
      
      errors = @suggestion.errors
      render :update do |page|
        if errors.empty?
          page << "$('#loader-category').hide();"
          page << "$('#tweet_text').val('')"
          page << "$('#post_notice').removeClass('error');"
          page << "$('#post_notice').addClass('success');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Your sugestion has been saved.');"
          page << "setTimeout('$(\"#post_notice\").fadeOut()',10000)"
        else
          page.redirect_to :back
        end
      end
    end
  end

  def tweet_suggestion
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @buffer_preference = @twitter_user.buffer_preferences.create(params[:buffer_preferences].merge(:status => "uninitialized"))
    @buffer_preference = @buffer_preference.update_run_at_new.last
    errors = @buffer_preference.errors

    @ordered_buffers = BufferPreference.where("status = ? AND twitter_user_id =?", "uninitialized", @twitter_user.id).order("run_at ASC")
    @active_time = @ordered_buffers.first.run_at.to_date rescue Date.today
    
    render :update do |page|
      if errors.empty?
        page.replace_html "buffer_wrapper", :partial => "buffer_preferences/new_buffer", :locals => {:ordered_buffers => @ordered_buffers, :active_time => @active_time}
        page << "$('#loader-buffer').hide();"
        page << "$('#tweet_text').val('')"
        page << "notification()"
      end
    end
  end

  def update_run_at
    @ti = @twitter_user.time_setting
    @tf = @ti.timeframe

    if @tf
      @post_at = @tf.value.to_i
      if @tf.unit.eql?("minutes")
        run_at = Time.now + @post_at.minutes
      elsif @tf.unit.eql?("hours")
        run_at = Time.now + @post_at.hours
      end
    else
      buffer_not_success = @twitter_user.buffer_preferences.where("status = 'uninitialized' AND run_at IS NOT NULL")
      minute_hours = @ti.other_interval.split("|") # => ["10:15 PM","h.m.p"...]
      mh_count = minute_hours.count
      all_run, mark_index = 0, 0
      
      year = Time.now.strftime('%Y')
      month = Time.now.strftime('%m')
      day = Time.now.strftime('%d')
      date = Time.now.strftime('%D')
      hour = Time.now.strftime('%H')
      minute = Time.now.strftime('%M')
      run_sat = nil
      
      unless buffer_not_success.blank?
        minute_hours.each_with_index do |mh, i|
          last_run = buffer_not_success.last.run_at.strftime("%H:%M")
          if mh.eql?(last_run)
            if i < (mh_count - 1)
              tmp = (i+1)
            elsif i == (mh_count - 1)
              tmp = 0
            end
            run_sat = minute_hours[tmp.to_i]
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
        at = 0
      else
        at = last_buffer_added_time
      end
      if last_buffer_run.strftime("%H:%M").eql?(minute_hours.last) || at > 0
        last_run = last_buffer_run.strftime("%H:%M").eql?(minute_hours.last)? last_buffer_added_time + 1 : last_buffer_added_time
        run_at = Time.utc(year, month, day, dj_min_hour[0], dj_min_hour[1]) + last_run.day
        added_time = last_buffer_added_time + 1 if run_sat.eql?(minute_hours.first)
      else
        run_at = Time.utc(year, month, day, dj_min_hour[0], dj_min_hour[1])
        added_time = 0
      end
    end
    
    @run_at = run_at
    @buffer_preference.update_attributes({:run_at => @run_at, :added_time => added_time})
  end
  
  private
  
  def list_suggestions
    @suggestions = Suggestion.all
    @suggestion = Suggestion.new
    @twitter_user_name = params[:twitter_name]
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    @buffer_preferences = @twitter_user.buffer_preferences.where("deleted_at IS NULL")
  end

end
