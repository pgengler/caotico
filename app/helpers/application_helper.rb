module ApplicationHelper

	def subhead
		[
			'a perpetual work in progress',
			'life, the universe, and mostly nothing',
		].sample
	end

	def markdown(text)
		pipeline = HTML::Pipeline.new([
			HTML::Pipeline::MarkdownFilter,
			HTML::Pipeline::SanitizationFilter,
		])
		pipeline.call(text)[:output].to_s.html_safe
	end

end
