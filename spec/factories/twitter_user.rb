Factory.define :twitter_user do |tu|
  tu.twitter_id (0...16).map{65.+(rand(25)).chr}.join
end