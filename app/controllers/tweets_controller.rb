class TweetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :twitter_account_required
  before_filter :get_buffer_preference
  before_filter :find_tweet, :only => [:edit, :update, :destroy]
  
  after_filter :respond_with_appropriate_data, :only => [:edit, :update, :destroy]
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
  end

  def update
    @tweet.update_attributes(params[:tweet])
  end

  def destroy
    @tweet.destroy
  end

  def sort
    tweet_order = params[:tweet]
    status = "ok"
    
    begin
      tweet_order.each_with_index do |tweet_id, i|
        @buffer_preference.tweets.find(tweet_id.to_i).update_attribute(:position, i)
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

  private

  def find_tweet
    @tweet = @buffer_preference.tweets.find(params[:id])
  end
  
  def respond_with_appropriate_data
    respond_with(@twitter_user, @buffer_preference, @tweet)
  end

end