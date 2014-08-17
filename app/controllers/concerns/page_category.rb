module PageCategory extend ActiveSupport::Concern

	def self.search_category_value(category_desc)
		if category_desc
			category = Category.find_by_name(category_desc)
			return category.id
		end
	end
	
	def self.search_template_value(template_desc)
    if template_desc
      template = Template.find(template_desc)
      return template.id
    end
  end

end
