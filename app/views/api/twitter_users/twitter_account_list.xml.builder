xml.instruct!
xml.Response do
  xml.twitter_account_list do 
    @twitter_users.each do |twitter_user|
      xml.twitter_name twitter_user.permalink
    end
    if @twitter_users.blank?
      xml.profile_image ""
    else
      xml.profile_image @twitter_users.first.profile_image_url
    end
  end
end