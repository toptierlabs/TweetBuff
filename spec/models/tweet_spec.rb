require 'spec_helper'

describe "Tweet", :type => :model do

  before(:each) do
    @user = Factory.create(:user)
  end

  it "should save" do
    tweet = Factory.create(:tweet)
    @user.tweets << tweet
    @user.save.should be_true
    tweet.save.should be_true
  end

  it "should convert urls to html links" do
    tweet = Factory.create(:tweet, {:body => "Hey there http://bit.ly/324tgGJ is super cool"})
    tweet.body_with_links.should == "Hey there <a href='http://bit.ly/324tgGJ' target='_click'>http://bit.ly/324tgGJ</a> is super cool"
    tweet = Factory.create(:tweet, {:body => "Hey there bit.ly/324tgGJ is super cool"})
    tweet.body_with_links.should == "Hey there <a href='http://bit.ly/324tgGJ' target='_click'>bit.ly/324tgGJ</a> is super cool"
  end

  it "should position itself correctly on save" do
    @user.tweets << Factory.create(:tweet)
    @user.save
    @user.tweets.last.position.should == 1

    @user.tweets << Factory.create(:tweet)
    @user.save
    @user.tweets.last.position.should == 2
  end

  it "should update positions after destroy" do
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.save
    @user.tweets.all[2].destroy
    @user.save
    @user.tweets.all[0].position.should == 1
    @user.tweets.all[1].position.should == 2
    @user.tweets.all[2].position.should == 3
  end

  it "should move positions down stack correctly" do
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.save
    # Move tweet down stack
    tweets = @user.tweets.all
    tweet = tweets[0]
    second_tweet = tweets[1]
    tweet.move_to(2)
    tweet.save
    tweet.position.should == 2
    new_top_tweet = @user.tweets.all(:conditions => {:position => 1}).first
    second_tweet.id.should == new_top_tweet.id
  end

  it "should move positions up stack correctly" do
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.tweets << Factory.create(:tweet)
    @user.save
    # Move tweet up stack
    tweets = @user.tweets.all
    tweet = tweets[3]
    third_tweet = tweets[2]
    tweet.move_to(1)
    tweet.save
    tweet.position.should == 1
    new_bottom_tweet = @user.tweets.all(:conditions => {:position => 4}).first
    third_tweet.id.should == new_bottom_tweet.id
  end

end
