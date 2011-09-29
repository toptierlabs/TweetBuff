class TwitterUsersController < ApplicationController

  before_filter :authenticate_user!

  TWITTER_API = {:key => "lKbJ5Wtlk010AbcaM6VA", :secret => "KXBLw1vtuF6GtOjiaT27XUpWQoLA1bXoVo3usfE"}

  def index
    @twitter_users = current_user.twitter_users
    unless @twitter_users.empty?
      twitter_name = @twitter_users.first.login
      twitter_user = current_user.twitter_users.find_by_permalink(twitter_name)
      @buffer_preference = twitter_user.buffer_preferences.new
      #user = User.find(current_user.id)
      @buffers = twitter_user.user.buffer_preferences.newest_order
    end
  end

  def tweet_to_twitter
    if request.xhr?
      render :update do |page|
        unless params[:tweet].empty?
          user = current_user.twitter_users.find_by_permalink(params[:twitter_name])
          Twitter.configure do |config|
            config.consumer_key       = TWITTER_API[:key]
            config.consumer_secret    = TWITTER_API[:secret]
            config.oauth_token        = user.access_token
            config.oauth_token_secret = user.access_secret
          end
          client = Twitter::Client.new
          client.update(params[:tweet])
          page << "$('#post_notice').removeClass('error');"
          page << "$('#post_notice').addClass('success');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Your tweet has been posted.');"
          page << "$('#loader').hide();"
          page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
        else
          page << "$('#post_notice').removeClass('success');"
          page << "$('#post_notice').addClass('error');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Please fill the form.');"
          page << "$('#loader').hide();"
          page << "setTimeout('$(\"#post_notice\").fadeOut()',3000)"
        end
      end
    end
  end
  
end