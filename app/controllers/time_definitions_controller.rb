class TimeDefinitionsController < ApplicationController
  before_filter :get_buffer_preference
  after_filter :respond_with_time_definitions, :except => [:create_time]

  respond_to :json, :js

  def index
  end

  def show
  end

  def new
    @time_definition = TimeDefinition.new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def create_time
    # This will create a new time for a given day
    # Default day is day 0 (sunday)
    time_def = TimeDefinition.new_time(@buffer_preference.tweet_basis, params[:time_definition])
    render(:json => time_def)
  end

protected

  def get_twitter_user
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
  end

  def get_buffer_preference
    get_twitter_user
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
  end
  
private

  def respond_with_time_definitions
    respond_with(@time_definitions)
  end

end