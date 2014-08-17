class Category < ActiveRecord::Base
	has_many :page
	belongs_to :category, :foreign_key => 'parent_category'
	validates :name, :presence => true, uniqueness: true
	validates :slug, :presence => true, uniqueness: true
  validates :parent_category, :presence => true
	def self.search(query)
		if query
		  where('name LIKE ?', "%#{query}%")
		else
		  all
		end
	end

end
