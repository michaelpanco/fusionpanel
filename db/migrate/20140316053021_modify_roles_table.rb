class ModifyRolesTable < ActiveRecord::Migration
  def change
    change_column :roles, :name, :string, :limit=>64
    change_column :roles, :permissions, :string, :limit=>512
    change_column :roles, :status, :string, :limit=>10
  end
end
