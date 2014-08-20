module ApplicationHelper
	
	def get_avatar_hash(email)

		email_address = email.downcase
		return Digest::MD5.hexdigest(email_address)

	end

	def widget id_or_alias

		if id_or_alias.is_a? Integer
			widget = Widget.find_by_id(id_or_alias)
		else
			widget = Widget.find_by alias: id_or_alias
		end

		if widget
		widget.content.html_safe
		else
			"<span style='color:#FC0004'>Widget '#{id_or_alias}' not found.</span>".html_safe
		end

	end
	
	def set_active menu, active_menu
		
		if menu == active_menu
			"active"
		end
		
	end

end
