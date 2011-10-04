class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many    :preferences
  has_many    :twitter_users
  has_many    :buffer_preferences
  has_many    :tweets
  has_many    :subcriptions
  has_many    :tweet_intervals
  has_one     :timezone
  scope :active_subscribtion, where(:active => true)

  
  after_create :mark_as_free_subcription

  private
  
  def mark_as_free_subcription
    Subcription.create!(:user_id => self.id, :plan_id => Plan.find_by_name('Free'), :active => true)
  end

end