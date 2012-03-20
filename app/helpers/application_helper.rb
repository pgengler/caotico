module ApplicationHelper

	def subhead
		[
			'a perpetual work in progress',
			'life, the universe, and mostly nothing',
		].sample
	end

	def wrap(text)
		paragraphs = text.split(/\n+/)
		paragraphs.map! do |paragraph|
			paragraph = wrap_paragraph(paragraph)
		end

		paragraphs.join("\n").html_safe
	end

	def wrap_paragraph(paragraph)
		unless /^<p/.match(paragraph)
			paragraph = '<p>' + paragraph;
		end
		unless /<\/p>$/.match(paragraph)
			paragraph = paragraph + '</p>'
		end
		paragraph
	end

end
