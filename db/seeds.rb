admin = AdminUser.create( :email => "bill@stackpointerllc.com",
  :name => "Bill Alton",
  :password => "temp4now",
  :password_confirmation => "temp4now")
user = User.create( :email => "bill@stackpointerllc.com",
  :name => "Bill Alton",
  :password => "temp4now",
  :password_confirmation => "temp4now")

plan = Plan.create!(
  [{:name=>"Free",:price=>0.0,:num_of_tweet_per_day=>6,:num_of_tweet_in_buffer=>20,:num_of_tweet_account=>1,:free_browser_ext=>true, :num_of_team_member_per_account => 0},
    {:name=>"Pro",:price=>4.99,:num_of_tweet_per_day=>25,:num_of_tweet_in_buffer=>60,:num_of_tweet_account=>5,:free_browser_ext=>true, :num_of_team_member_per_account => 2},
    {:name=>"Premium",:price=>30.0,:num_of_tweet_per_day=>0,:num_of_tweet_in_buffer=>0,:num_of_tweet_account=>10,:free_browser_ext=>true, :num_of_team_member_per_account => 5}]
)

timeframe = Timeframe.create(
  [
    {:name=>"10 minutes",:value=>10,:unit=>"minutes"},
    {:name=>"15 minutes",:value=>15,:unit=>"minutes"},
    {:name=>"30 minutes",:value=>30,:unit=>"minutes"},
    {:name=>"2 hours",:value=>2,:unit=>"hours"},
    {:name=>"3 hours",:value=>3,:unit=>"hours"},
    {:name=>"4 hours",:value=>4,:unit=>"hours"},
    {:name=>"5 hours",:value=>5,:unit=>"hours"},
    {:name=>"6 hours",:value=>6,:unit=>"hours"},
    {:name=>"12 hours",:value=>12,:unit=>"hours"}
  ]
)