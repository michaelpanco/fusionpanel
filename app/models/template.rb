class Template < ActiveRecord::Base
  has_many :page
  validates :name, :presence => true, uniqueness: true
  def modified
    self.updated_at.to_time.strftime('%b %d, %Y at %I:%M %p')
  end
  
  def self.search(query)
    if query
      where('name LIKE ?', "%#{query}%")
    else
      all
    end
  end
  
end
