class RemoveMetaIdFromPages < ActiveRecord::Migration
  def change
    remove_column :pages, :meta_id, :integer
  end
end
