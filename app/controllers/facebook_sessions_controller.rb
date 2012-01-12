require 'net/http'
require 'uri'

class FacebookSessionsController < ApplicationController
  def new
    fb_auth = FbGraph::Auth.new(API_KEY, SECRET_KEY)
    fb_auth.client

    fb_auth.access_token
    fb_auth.user        
    
    client = fb_auth.client
    client.redirect_uri = "#{SERVER_URL}/facebook/callback"

    # redirect user to facebook
    redirect_to client.authorization_uri(
      {:scope => [:publish_stream, :offline_access, :email, :user_interests, :friends_interests ]}
    )
    
    access_token = client.access_token!
    me = FbGraph::User.me(access_token)
  end
  
  def oauth_callback
    fb_auth = FbGraph::Auth.new(API_KEY, SECRET_KEY)
    
    client = fb_auth.client
    client.redirect_uri = "#{SERVER_URL}/facebook/callback"
    client.authorization_code = params[:code]
    access_token = client.access_token!
    user = FbGraph::User.me(access_token).fetch
    
    @user = TwitterUser.new(
      :protected => "",
      :user_id => current_user.id,
      :friends_count => user.friends.count,
      :statuses_count => user.statuses.count,
      :followers_count => "",
      :utc_offset => "",
      :login => user.username,
      :access_secret => "", 
      :remember_token=> "", 
      :name => user.name, 
      :profile_image_url => user.picture, 
      :url => "" , 
      :time_zone => user.timezone, 
      :permalink => "", 
      :account_type => "facebook" )
    @user.twitter_id = user.identifier
    @user.access_token = user.access_token.to_s
    @user.save
    
    redirect_to twitter_settings_path(:twitter_name => @user.login)
  end
end