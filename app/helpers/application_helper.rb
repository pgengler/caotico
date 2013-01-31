module ApplicationHelper

	def subhead
		[
			'a perpetual work in progress',
			'life, the universe, and mostly nothing',
		].sample
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
		], context)
		pipeline.call(text)[:output].to_s.html_safe
	end

end
