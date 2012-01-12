ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "dateorfrape.com",
  :user_name            => "dummy@41studio.com",
  :password             => "ssstsecret",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "tweetbuff.com"