every 1.minute do
  runner "BufferPreference.post_tweet", :environment => :development
  #runner "BufferPreference.test", :environment => :development
end
