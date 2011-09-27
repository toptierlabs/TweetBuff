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