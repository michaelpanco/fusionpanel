class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :name
      t.string :slug
      t.string :file_type
      t.string :location
      t.integer :owner
      t.integer :parent
      t.string :visibility
      t.timestamps
    end
  end
end