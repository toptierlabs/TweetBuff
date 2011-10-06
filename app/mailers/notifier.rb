class Notifier < ActionMailer::Base
  default :from => "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.buffer_run_out.subject
  #
  def buffer_run_out(user, twitter_user)
    @greeting = "Hi"
    @user = user
    @twitter_user = twitter_user

    mail :to => user.email, :subject => "TweetBuff - you are running out of buffer."
  end
end
