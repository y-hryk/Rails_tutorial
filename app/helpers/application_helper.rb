module ApplicationHelper

	#ページごとのタイトルを返す
	def full_title(page_title = '')
		base_title = "Ruby on Rails Tutorial Sample App"

		if base_title.empty?
			return base_title
		else
			return page_title + " | " + base_title
		end

	end


end
