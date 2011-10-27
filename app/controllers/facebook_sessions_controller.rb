require 'net/http'
require 'uri'

class FacebookSessionsController < ApplicationController

  #  def new
  #    redirect_to :back
  #  end
  
  #  def new
  #    @user, session[:new_register] = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
  #    if @user.persisted?
  #      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
  #      sign_in_and_redirect @user, :event => :authentication
  #    else
  #      session["devise.facebook_data"] = env["omniauth.auth"]
  #      redirect_to new_user_registration_url
  #    end
  #  end

  def new
    fb_auth = FbGraph::Auth.new("174091022679493", "1c016c320fc44d6014aecd50d7761880")
    fb_auth.client

    fb_auth.access_token
    fb_auth.user        
    
    client = fb_auth.client
    client.redirect_uri = "http://localhost:3000/facebook/callback"

    # redirect user to facebook
    redirect_to client.authorization_uri(
      :scope => [:email, :read_stream, :offline_access]
    )
    access_token = client.access_token!
    me = FbGraph::User.me(access_token)
  end
  
  def oauth_callback
    fb_auth = FbGraph::Auth.new("174091022679493", "1c016c320fc44d6014aecd50d7761880")
    
    client = fb_auth.client
    client.redirect_uri = "http://localhost:3000/facebook/callback"
    client.authorization_code = params[:code]
    access_token = client.access_token!

    user = FbGraph::User.me(access_token).fetch
    
    user = TwitterUser.new(:user_id => current_user.id, :friends_count => user.friends.count, :statuses_count => user.posts.count, :twitter_id => user.__id__, :login => user.username, :access_token => user.access_token, :access_secret => "", :remember_token=> "", :name => user.name, :profile_image_url => user.picture, :url => "" , :time_zone => user.timezone, :permalink => "", :account_type => "facebook" )
    user.save(false)
    
    redirect_to twitter_settings_path(:twitter_name => user.login)
  end
end