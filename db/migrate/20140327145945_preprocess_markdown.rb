class PreprocessMarkdown < ActiveRecord::Migration[4.2]

  def up
		add_column :posts, :rendered_content, :text
		Post.all.each do |post|
			post.rendered_content = MarkdownRenderer.render(post.content)
			post.save!
		end
  end

  def down
		remove_column :posts, :rendered_content
  end
end
