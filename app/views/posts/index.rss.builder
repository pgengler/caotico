xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
	xml.channel do
		xml.title 'pgengler.net'
		xml.link posts_url

		@posts.each do |post|
			xml.item do
				xml.title post.title
				xml.description markdown(post.content)
				xml.pubDate post.created_at.to_s(:rfc822)
				xml.link post_url_with_slug(post)
				xml.guid post_url(post)
			end
		end
	end
end
