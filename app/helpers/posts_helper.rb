module PostsHelper

	def post_path_with_slug(post)
		add_slug post_path(post), post
	end

	def post_url_with_slug(post)
		add_slug post_url(post), post
	end

	def tag_list(post)
		post.tag_list.map { |tag|
			link_to tag, tag_path(tag)
		}.join(' / ').html_safe
	end

private

	def add_slug(base, post)
		"#{base}/#{post.title.parameterize}"
	end
end
