class BufferPreferencesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_twitter_user

  respond_to :html, :json


  # get     ":twitter_name/buffers"
  def index
    @buffer_preferences = @twitter_user.buffer_preferences
    respond_with(@twitter_user, @buffer_preferences)
  end

  # get     ":twitter_name/:buffer_name"
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

  # get     ":twitter_name/buffers/new"
  def new
    @buffer_preference = @twitter_user.buffer_preferences.new()
    respond_with(@twitter_user, @buffer_preference)
  end

  # post    ":twitter_name/buffers"
  def create
    @buffer_preference = @twitter_user.buffer_preferences.create(params[:buffer_preference])
    if @buffer_preference.errors.empty?
      queue_to_dj
      if request.xhr?
        render :update do |page|
          page << "$('#post_notice').removeClass('error');"
          page << "$('#post_notice').addClass('success');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Your tweet has been queued.');"
          page << "$('#loader').hide();"
          page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
        end
      end
    else
      respond_with(@twitter_user, @buffer_preference)
    end
  end

  # get     ":twitter_name/:buffer_name/edit"
  def edit
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    respond_with(@twitter_user, @buffer_preference)
  end

  # put     ":twitter_name/:buffer_name"
  def update
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
    @buffer_preference.update_attributes(params[:buffer_preferences])
    respond_with(@twitter_user, @buffer_preference) do |format|
      format.json { render(:json => {:status => :ok})}
    end
  end

  # delete  ":twitter_name/:buffer_name"
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
    redirect_to(twitter_settings_path) and return if @twitter_user.blank?
  end

  def queue_to_dj
    @ti  = @twitter_user.tweet_interval
    @tf = @ti.timeframe
    if @tf
      @post_at = @tf.value.to_i
      if @tf.unit.eql?("minutes")
        run_at = Time.now + @post_at.minutes
      elsif @tf.unit.eql?("hours")
        run_at = Time.now + @post_at.hours
      end
    else
      minute_hours = @ti.other_interval.split(".")
      year = Time.now.strftime('%Y')
      month = Time.now.strftime('%m')
      day = Time.now.strftime('%d')
      hour = Time.now.strftime('%H')
      minute = Time.now.strftime('%M')
      minute_hour = minute_hours[0]
      minute_hour = minute_hour.to_i + 12  if minute_hours[2].eql?('pm')
      if minute_hour.to_i < hour.to_i
        run_at = Time.utc(year,month,day,minute_hour,minute_hours[1]) + 1.day
      elsif minute_hour.to_i == hour.to_i
        if minute_hours[1].to_i < minute
          run_at = Time.utc(year,month,day,minute_hour,minute_hours[1]) + 1.day
        else
          run_at = Time.utc(year,month,day,minute_hour,minute_hours[1])
        end
      else
        run_at = Time.utc(year,month,day,minute_hour,minute_hours[1])
      end
    end
    #queue to delayed job
    Delayed::Job.enqueue(PostTweet.new(@twitter_user.id,@buffer_preference.id),1,run_at)
  end
  
end