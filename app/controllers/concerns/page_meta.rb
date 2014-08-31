module PageMeta extend ActiveSupport::Concern
	
	def self.create_meta_tags meta_keywords, meta_description, no_index, no_follow
		
		meta_tags = ""
		
		if meta_keywords != ""
			meta_tags += "<meta name=\"keywords\" content=\"#{meta_keywords}\" />\n"
		else
			generic_meta_keywords = Setting.find_by_setting_name('generic_meta_keywords').setting_value
			meta_tags += "<meta name=\"keywords\" content=\"#{generic_meta_keywords}\" />\n"
		end
		
		if meta_description != ""
			meta_tags += "<meta name=\"description\" content=\"#{meta_description}\" />\n"
		else
			generic_meta_description = Setting.find_by_setting_name('generic_meta_description').setting_value
			meta_tags += "<meta name=\"description\" content=\"#{generic_meta_description}\" />\n"
		end
		
		if no_index == true && no_follow == true
			meta_tags += "<meta name=\"robots\" content=\"noindex, nofollow\" />\n"
		elsif no_index == false && no_follow == true
			meta_tags += "<meta name=\"robots\" content=\"index, nofollow\" />\n"
		elsif no_index == true && no_follow == false
			meta_tags += "<meta name=\"robots\" content=\"noindex, follow\" />\n"
		end
		
		return meta_tags.html_safe
		
	end
	
end
