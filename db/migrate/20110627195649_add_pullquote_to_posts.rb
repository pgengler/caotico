class AddPullquoteToPosts < ActiveRecord::Migration
  def self.up
		add_column :posts, :pullquote, :text
  end

  def self.down
		remove_column :posts, :pullquote
  end
end
