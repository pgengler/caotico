module ApplicationHelper

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

end
