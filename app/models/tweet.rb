class Tweet < ActiveRecord::Base

  belongs_to :user
  belongs_to :buffer_preference

  validates_presence_of :title
  validates_presence_of :body

  before_create :set_position
  after_destroy :update_positions

  # TODO come up with a way to read preferences and determine the timeframe in which this tweet will be posted
  def due_at(part=:datetime)
    case part
    when :date

    when :time

    when :datetime

    end
  end

  # TESTED: PASSING
  def body_with_links
    self.body.gsub(/(http\:\/\/)*([a-z0-9_-]+\.[a-z]{2,4}\/[^\s]*)/) do |url|
      url_with_protocol = url =~ /^http\:\/\// ? url : "http://#{url}"
      "<a href='#{url_with_protocol}' target='_click'>#{url}</a>"
    end
  end

  # TESTED: PASSING
  def move_to(new_position)
    old_position = self.position
    return true if old_position == new_position
    if new_position > old_position
      # If the new position is further down the list than the old position
      # 1 => 3
      # 2 => 1
      # 3 => 2
      # 4 => 4
      # decrement positions lte to new position, and gt old position
      Tweet.update_all("position = position - 1", ["position <= ? AND position > ? AND user_id = ?", new_position, old_position, self.user_id])
    else
      # If the new position is further up than the old position
      # 1 => 2
      # 2 => 3
      # 3 => 1
      # 4 => 4
      # increment gte new position and lt old position
      Tweet.update_all("position = position + 1", ["position >= ? AND position < ? AND user_id = ?", new_position, old_position, self.user_id])
    end
    self.update_attribute(:position, new_position)
  end

protected

  # TESTED: PASSING
  def set_position
    self.position ||= (Tweet.maximum(:position) || 0) + 1
  end

  # TESTED: PASSING
  def update_positions
    old_position = self.position
    Tweet.update_all("position = position - 1", ["position > ? AND user_id = ?", old_position, self.user_id])
  end

end
