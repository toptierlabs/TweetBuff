class TweetsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_buffer_preference
  after_filter :layout_renderer

  respond_to :html, :json

  def index
    @tweets = current_user.tweets.all
    respond_with(@twitter_user, @buffer_preference, @tweets)
  end

  def new
    @tweet = current_user.tweets.new
    respond_with(@twitter_user, @buffer_preference, @tweet) do |format|
      format.html {
        render(:layout => false) and return if params[:no_layout] == "true"
      }
    end
  end

  def create
    @tweet = current_user.tweet.create(params[:tweet])
    respond_with(@twitter_user, @buffer_preference, @tweet) do |format|
      format.json {
        render(:json => {:tweet => @tweet, :bp_permalink => @buffer_preference.permalink})
      }
    end
  end

  def edit
    @tweet = Tweet.find(:conditions => {:user_id => current_user.id, :id => params[:id]})
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

  def update
    @tweet = Tweet.find(:conditions => {:user_id => current_user.id, :id => params[:id]})
    @tweet.update_attributes(params[:tweet])
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

  def destroy
    @tweet = Tweet.find(:conditions => {:user_id => current_user.id, :id => params[:id]})
    @tweet.destroy
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end


protected

  def get_twitter_user
    @twitter_user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
  end

  def get_buffer_preference
    get_twitter_user
    @buffer_preference = @twitter_user.buffer_preferences.find_by_permalink(params[:buffer_name])
  end

  def layout_renderer

  end

end