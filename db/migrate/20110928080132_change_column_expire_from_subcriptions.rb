class ChangeColumnExpireFromSubcriptions < ActiveRecord::Migration
  def self.up
    change_column :subcriptions, :expire, :date
  end

  def self.down
    change_column :subcriptions, :expire, :datetime
  end
end
