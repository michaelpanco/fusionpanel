class Page < ActiveRecord::Base

	has_one :meta, :foreign_key => 'id'
	belongs_to :user, :foreign_key => 'created_by'
	belongs_to :category
	belongs_to :template
	before_save :set_status
  accepts_nested_attributes_for :meta
	validates :content_title, :presence => true
	validates :url_slug, :presence => true
	validates :content, :presence => true
  validates :template_id, :presence => true
  
  PAGE_NOT_FOUND_ERR_MSG = "Sorry, Failed to load the website's homepage. It seems it was misconfigure by the website administrator."
  
	def set_status
	  self.status = self.status.downcase
	end

	def modified
		self.updated_at.to_time.strftime('%b %d, %Y at %I:%M %p')
	end

	def self.search(query)
		if query
		  where('content_title LIKE ?', "%#{query}%")
		else
		  all
		end
	end
	
	def url
	  cat_id = self.category_id #5
    category_container = ""
	  if self.category_id != 1
      begin
  	  category = Category.find(cat_id)
  	  category_slug = category.slug #personalloan
  	  category_parent = category.parent_category #3
  	  category_container = category_slug + "/" + category_container #personalloan
  	  cat_id = category_parent
  	  end while category_parent != 1
  	  page_url = category_container
	  end
	  
	  return category_container
	  
	end

	def self.where_value(hash_params)
		case hash_params.length
		when 1
			where("#{hash_params.keys[0]} = ?", hash_params.values[0])
		when 2
			where("#{hash_params.keys[0]} = ? AND #{hash_params.keys[1]} = ?", hash_params.values[0], hash_params.values[1])
		else
			where("#{hash_params.keys[0]} = ? AND #{hash_params.keys[1]} = ? AND #{hash_params.keys[2]} = ?", hash_params.values[0], hash_params.values[1], hash_params.values[2])
		end
	end


end
