class BufferPreferencesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :twitter_account_required
  before_filter :get_twitter_user

  respond_to :html, :json

  def index
    @buffer_preferences = @twitter_user.buffer_preferences.all(:conditions => ["deleted_at IS NULL"])
    respond_with(@twitter_user, @buffer_preferences)
  end

  def show
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    respond_with(@twitter_user, @buffer_preference) do |format|
      format.json {
        render(:json => { :twitter_user => {
              :login => @twitter_user.login,
              :name => @twitter_user.name},
            :buffer_preference => {
              :tweet_mode => @buffer_preference.tweet_mode,
              :name => @buffer_preference.name,
              :permalink => @buffer_preference.permalink}})
      }
    end
  end

  def new
    @buffer_preference = @twitter_user.buffer_preferences.new()
    respond_with(@twitter_user, @buffer_preference)
  end
  
  def create
    if request.xhr?
      unless @twitter_user.time_setting.blank?
        @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
        @buffers = BufferPreference.where("twitter_user_id = ? AND status = ?", @twitter_user.id, "uninitialized").count
        unless @buffers.eql?(max_tweet_buffer_for_user(current_user))
          render :update do |page|
            if params[:buffer_preference][:name].blank?
              page << "$('#loader-buffer').hide();"
              page << "error()"
            else
              buffer_preference = @twitter_user.buffer_preferences.create(params[:buffer_preference].merge(:status => "uninitialized"))
              buffer_preference = buffer_preference.update_run_at_new.last
              ordered_buffers = BufferPreference.where("status = ? AND twitter_user_id =?", "uninitialized", @twitter_user.id).order("run_at ASC")
              active_time = ordered_buffers.first.run_at.to_date rescue Date.today
              
              page.replace_html :buffer_wrapper, :partial => "new_buffer", :locals => {:buffer => buffer_preference, :ordered_buffers => ordered_buffers, :active_time => active_time}
              page << "$('#loader-buffer').hide();"
              page << "$('#tweet_text').val('')"
              page << "notification()"
            end
          end
        else
          render :update do |page|
            page.redirect_to :back
          end
        end
      end
    end
  end

  def edit
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    respond_with(@twitter_user, @buffer_preference)
  end

  def update
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    @buffer_preference.update_attributes(params[:buffer_preferences])
    respond_with(@twitter_user, @buffer_preference) do |format|
      format.json { render(:json => {:status => :ok})}
    end
  end

  def destroy
    respond_with(@twitter_user, @buffer_preference)
  end

  def new_tweet_time
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    render :layout => false
  end

  protected

  def get_twitter_user
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    if @twitter_user.account_type.eql?("twitter")
      redirect_to(twitter_settings_path) and return if @twitter_user.blank?
    else
      redirect_to(facebook_settings_path) and return if @twitter_user.blank?
    end
  end

  def update_run_at
    twitter_user = TwitterUser.find_by_permalink(params[:twitter_name])
    time_setting = TimeSetting.find_by_twitter_user_id(twitter_user.id)
    
    buffers = BufferPreference.where("twitter_user_id = ? AND status = ?", twitter_user.id, "uninitialized")
    b = buffers.last
    b.run_at = nil
    b.save!
    
    times = time_setting.time_period.split(",")
    
    buffer = buffers[buffers.count - 2]
    last_time = (buffer.run_at).strftime("%H:%M")
    last_date = (buffer.run_at).strftime("%Y-%m-%d")
    i = times.index(last_time)
    
    if times[i+1].nil?
      run_at = times.first
      @buffer_preference.update_attributes({:run_at => run_at})
    else
      run_at = times[i+1]
      
      year = last_date.split("-")[0]
      month = last_date.split("-")[1]
      day = last_date.split("-")[2]
      hour = run_at.split(":")[0]
      min = run_at.split(":")[1]
      
      time = Time.utc(year, month, day, hour, min, nil, "+00:00")
      @buffer_preference.update_attributes({:run_at => time})
    end
  end
    
  def max_tweet_buffer_for_user(user)
    accounts = TwitterUser.find_all_by_user_id(user.id).count
    subcription = Subcription.active_subcription(user).first
    subcription.plan.num_of_tweet_in_buffer
  end

end