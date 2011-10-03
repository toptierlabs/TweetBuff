class PostTweet < Struct.new(:twitter_user_id, :buffer_id)
  def perform
    puts "========================="
    puts "Starting job"
    puts "========================="
    user = TwitterUser.find(twitter_user_id)
    buffer = user.buffer_preferences.find(buffer_id)
    Twitter.configure do |config|
      config.consumer_key       = TWITTER_API[:key]
      config.consumer_secret    = TWITTER_API[:secret]
      config.oauth_token        = user.access_token
      config.oauth_token_secret = user.access_secret
    end
    client = Twitter::Client.new
    client.update(buffer.name)
    buffer.destroy
  end
end
