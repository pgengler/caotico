class Post < ActiveRecord::Base

	include ApplicationHelper

	acts_as_ordered_taggable

	default_scope { order('created_at DESC') }
	paginates_per 10

	validates :title, presence: true
	validates :content, presence: true

	before_save :render_markdown

	private

	def render_markdown
		self.rendered_content = markdown(self.content)
	end

end
