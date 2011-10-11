xml.instruct!
xml.Response do
  xml.twitter_account_list do 
    @twitter_users.each do |twitter_user|
      xml.twitter_name twitter_user.permalink
    end
    xml.twitter_name "dadan"
    xml.twitter_name "saepul"
    xml.twitter_name "ramdan"
  end
end