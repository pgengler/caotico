class PreprocessMarkdown < ActiveRecord::Migration
	include ApplicationHelper

  def up
		add_column :posts, :rendered_content, :text
		Post.all.each do |post|
			post.rendered_content = markdown(post.content)
			post.save!
		end
  end

  def down
		remove_column :posts, :rendered_content
  end
end
