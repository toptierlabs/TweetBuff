class TwitterSessionsController < ApplicationController

  def new
    oauth_callback = request.protocol + request.host_with_port + '/twitter/callback'
    @request_token = TwitterAuth.consumer.get_request_token({:oauth_callback => oauth_callback})
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
   
    url = @request_token.authorize_url
    url << "&oauth_callback=#{CGI.escape(TwitterAuth.oauth_callback)}" if TwitterAuth.oauth_callback?      
    redirect_to url
  end
  
  def oauth_callback
    unless session[:request_token] && session[:request_token_secret] 
      authentication_failed('No authentication information was found in the session. Please try again.') and return
    end

   unless params[:oauth_token].blank? || session[:request_token] ==  params[:oauth_token]
     authentication_failed('Authentication information does not match session information. Please try again.') and return
   end

    @request_token = OAuth::RequestToken.new(TwitterAuth.consumer, session[:request_token], session[:request_token_secret])

    oauth_verifier = params["oauth_verifier"]
    @access_token = @request_token.get_access_token(:oauth_verifier => oauth_verifier)
    
    # The request token has been invalidated
    # so we nullify it in the session.
    session[:request_token] = nil
    session[:request_token_secret] = nil

    @twitter_user = TwitterUser.identify_or_create_from_access_token(@access_token)
    @twitter_user.user = current_user
    @twitter_user.save
    redirect_to twitter_settings_path(:twitter_name => @twitter_user.login)
  rescue Net::HTTPServerException => e
    case e.message
      when '401 "Unauthorized"'
        authentication_failed('This authentication request is no longer valid. Please try again.') and return
      else
        authentication_failed('There was a problem trying to authenticate you. Please try again.') and return
    end 
  end

protected

  def authentication_failed(message = "Authentication failed")
    flash[:error] = message
    redirect_to(twitter_settings_path)
  end
  
end