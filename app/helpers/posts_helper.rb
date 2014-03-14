module PostsHelper

	def post_path_with_slug(post)
		add_slug post_path(post), post
	end

	def post_url_with_slug(post)
		add_slug post_url(post), post
	end

	def tag_list(post)
		content_tag(:ul, class: 'tags') do
			post.tag_list.collect do |tag|
				concat content_tag(:li) { link_to tag, tag_path(tag) }
			end
		end
	end

	def summary(post, num_chars=200)
		text_content(markdown(post.content)).slice(0..num_chars)
	end

private

	def add_slug(base, post)
		"#{base}/#{post.title.parameterize}"
	end
end
