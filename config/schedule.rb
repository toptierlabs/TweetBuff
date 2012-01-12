every 1.minute do
  runner "BufferPreference.post_tweet", :environment => :development
end

every 1.day do
  runner "BufferPreference.send_notification"
end

every :midnight do
  runner "BufferPreference.update_added_time"
end
