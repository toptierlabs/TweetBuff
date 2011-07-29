class BufferPreferencesController < ApplicationController

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
    respond_with(@twitter_user, @buffer_preference)
  end

  # get     ":twitter_name/buffers/new"
  def new
    @buffer_preference = BufferPreference.new(:twitter_user_id => )
    respond_with(@twitter_user, @buffer_preference)
  end

  # post    ":twitter_name/buffers"
  def create
    @buffer_preference = @twitter_user.buffer_preferences.create(params[:buffer_preference])
    respond_with(@twitter_user, @buffer_preference)
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
    respond_with(@twitter_user, @buffer_preference)
  end

  # delete  ":twitter_name/:buffer_name"
  def destroy
    respond_with(@twitter_user, @buffer_preference)
  end

protected

  def get_twitter_user
    @twitter_user = current_user.twitter_users.find_by_login(params[:twitter_name])
  end

end