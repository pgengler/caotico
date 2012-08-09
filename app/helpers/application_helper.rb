module ApplicationHelper

	def subhead
		[
			'a perpetual work in progress',
			'life, the universe, and mostly nothing',
		].sample
	end

  def markdown(text)
    BlueCloth.new(text).to_html.html_safe
  end

end
