module PostsHelper

	def post_path_with_slug(post)
		post_path(post) + "/#{post.title.parameterize}"
	end

end
