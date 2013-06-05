class Post < ActiveRecord::Base

	attr_accessible :title, :content, :tag_list
	acts_as_taggable

	default_scope order('created_at DESC')
	paginates_per 10

	validates :title, presence: true
	validates :content, presence: true

	def to_param
		"#{id}/#{title.parameterize}"
	end

end
