class Widget < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'created_by'
  
  validates :title, :presence => true
  validates :alias, :presence => true, uniqueness: true
  validates :content, :presence => true
  
  def modified
    self.updated_at.to_time.strftime('%b %d, %Y at %I:%M %p')
  end
  
  def self.search(query)
    if query
      where('title LIKE ?', "%#{query}%")
    else
      all
    end
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
