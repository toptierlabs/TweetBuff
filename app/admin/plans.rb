ActiveAdmin.register Plan do
  filter :name  
  filter :price

  index do
    column :name
    column :price
    column :num_of_tweet_per_day
    column :num_of_tweet_in_buffer
    column :num_of_tweet_account
    column :num_of_team_member_per_account
    default_actions
  end
end
