class TweetsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :twitter_account_required
  before_filter :get_buffer_preference
  after_filter :layout_renderer

  respond_to :html, :json

  def index
    @tweets = @buffer_preference.tweets.all
    respond_with(@twitter_user, @buffer_preference, @tweets)
  end

  def new
    @tweet = @buffer_preference.tweets.new
    respond_with(@twitter_user, @buffer_preference, @tweet) do |format|
      format.html {
        render(:layout => false) and return if params[:no_layout] == "true"
      }
    end
  end

  def create
    @tweet = @buffer_preference.tweets.create(params[:tweet])
    respond_with(@twitter_user, @buffer_preference, @tweet) do |format|
      format.json {
        render(:json => {:tweet => @tweet, :bp_permalink => @buffer_preference.permalink})
      }
    end
  end

  def edit
    @tweet = @buffer_preference.tweets.find_by_id(params[:id])
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

  def update
    @tweet = @buffer_preference.tweets.find_by_id(params[:id])
    @tweet.update_attributes(params[:tweet])
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

  def destroy
    @tweet = @buffer_preference.tweets.find_by_id(params[:id])
    @tweet.destroy
    
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

  def sort
    tweet_order = params[:tweet]
    status = "ok"
    begin
      tweet_order.each_with_index do |tweet_id, index|
        @buffer_preference.tweets.find_by_id(tweet_id.to_i).update_attribute(:position, index)
      end
    rescue
      status = "error"
    end
    render(:json => {:status => status})
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