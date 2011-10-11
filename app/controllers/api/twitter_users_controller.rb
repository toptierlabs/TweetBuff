class Api::TwitterUsersController < ApplicationController
  protect_from_forgery :except => [:twitter_account_list, :post_to_twitter]
  before_filter :authenticate_user!
  
  def twitter_account_list
    @twitter_users = current_user.twitter_users
    
    respond_to do |format|
      format.xml
    end
  end
  
  def post_to_twitter
    params[:tweet_message].empty?
    user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
    Twitter.configure do |config|
      config.consumer_key       = TWITTER_API[:key]
      config.consumer_secret    = TWITTER_API[:secret]
      config.oauth_token        = user.access_token
      config.oauth_token_secret = user.access_secret
    end
    client = Twitter::Client.new
    status = params[:tweet_message]
    url = status.match(/https?:\/\/[\S]+/)
    debugger
    unless url.nil?
      bitly_api = current_user.bitly_api
      unless bitly_api.nil?
        bitly = Bitly.new(bitly_api.bitly_name, bitly_api.api_key)
        bitly_url = bitly.shorten(url.to_s).short_url
        status = status.gsub(url.to_s,bitly_url)
      end
    end
    client.update(status)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def send_to_buff
    
  end
end
  