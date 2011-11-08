class TimeSetting < ActiveRecord::Base
  belongs_to :timeframe
  belongs_to :twitter_user
  
  after_save :update_run_at_when_saved_time_setting
  
  def update_run_at_when_saved_time_setting
    twitter_user = self.twitter_user
    BufferPreference.update_all("run_at = NULL", "twitter_user_id = #{twitter_user.id}")
    # BufferPreference.update_all("twitter_user_id = #{twitter_user.id}")
    buffer = twitter_user.buffer_preferences.first
    buffer.update_run_at_new
  end
end
