module ApplicationHelper

	def page_title
		if @title
			"#{@title} - pgengler.net"
		else
			"pgengler.net"
		end
	end

	def markdown(text)
		MarkdownRenderer.render(text)
	end

	def text_content(html)
		strip_tags html
	end

	def local_time(time)
		time.in_time_zone('Eastern Time (US & Canada)')
	end

end
