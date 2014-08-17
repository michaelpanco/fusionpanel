class Role < ActiveRecord::Base
  
  PERMISSIONS = ["can_view_pages",
    "can_modify_pages",
    "can_view_categories",
    "can_modify_categories",
    "can_view_widgets",
    "can_modify_widgets",
    "can_view_assets",
    "can_modify_assets",
    "can_view_users",
    "can_invite_users",
    "can_modify_users",
    "can_view_roles",
    "can_modify_roles",
    "can_view_settings",
    "can_modify_settings",
    "can_view_templates",
    "can_modify_templates"]
 
  has_many :user
  validates :name, :presence => true, uniqueness: true
  
  def self.search(query)
    if query
      where('name LIKE ?', "%#{query}%")
    else
      all
    end
  end
  
end
