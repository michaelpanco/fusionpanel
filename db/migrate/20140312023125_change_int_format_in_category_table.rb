class ChangeIntFormatInCategoryTable < ActiveRecord::Migration
  def up
   change_column :categories, :parent_category, :int, :limit=>6
  end

  def down
   change_column :categories, :parent_category, :int, :limit=>6
  end
end
