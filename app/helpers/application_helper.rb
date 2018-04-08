require 'linguist'

module ApplicationHelper

	def page_title
		if @title
			"#{@title} - pgengler.net"
		else
			"pgengler.net"
		end
	end

	def markdown(text)
		whitelist = HTML::Pipeline::SanitizationFilter::WHITELIST
		whitelist[:attributes].merge! 'p' => [ 'data-pullquote' ]
		context = {
			:whitelist => whitelist
		}
		pipeline = HTML::Pipeline.new([
			HTML::Pipeline::MarkdownFilter,
			HTML::Pipeline::SanitizationFilter,
			HTML::Pipeline::SyntaxHighlightFilter,
		], context)
		pipeline.call(text)[:output].to_s.html_safe
	end

	def text_content(html)
		strip_tags html
	end

	def local_time(time)
		time.in_time_zone('Eastern Time (US & Canada)')
	end

end
