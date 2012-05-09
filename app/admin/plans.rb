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
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :price
      f.input :num_of_tweet_per_day
      f.input :num_of_tweet_in_buffer
      f.input :num_of_tweet_account
      f.input :num_of_team_member_per_account
      f.input :free_browser_ext
      f.input :timeframes
    end
    f.buttons
  end
end
