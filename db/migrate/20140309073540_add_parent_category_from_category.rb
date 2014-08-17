class AddParentCategoryFromCategory < ActiveRecord::Migration
  def change
    add_column :categories, :parent_category, :string, :limit => 32
  end
end
