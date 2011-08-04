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
    @buffer_preference = @twitter_user.buffer_preferences.find_by_name(params[:buffer_name])
    respond_with(@twitter_user, @buffer_preference) do |format|
      format.json {
        render(:json => { :twitter_user => {
                            :login => @twitter_user.login,
                            :name => @twitter_user.name},
                          :buffer_preference => {
                            :tweet_mode => @buffer_preference.tweet_mode,
                            :name => @buffer_preference.name}})
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
    if @buffer_preference.errors.empty? && !request.xhr?
      redirect_to(twitter_user_buffer_preferences_path(@twitter_user) + "#buffer=#{@buffer_preference.name}")
    else
      respond_with(@twitter_user, @buffer_preference)
    end
  end

  # get     ":twitter_name/:buffer_name/edit"
  def edit
    @buffer_preference = @twitter_user.buffer_preferences.find_by_name(params[:buffer_name])
    respond_with(@twitter_user, @buffer_preference)
  end

  # put     ":twitter_name/:buffer_name"
  def update
    @buffer_preference = @twitter_user.buffer_preferences.find_by_name(params[:buffer_name])
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
    @buffer_preference = @twitter_user.buffer_preferences.find_by_name(params[:buffer_name])
    render :layout => false
  end

protected

  def get_twitter_user
    @twitter_user = current_user.twitter_users.find_by_login(params[:twitter_name])
  end

end