class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :created_by
      t.string :content_title
      t.text :content
      t.string :url_slug
      t.string :status
      t.integer :category_id
      t.integer :meta_id
      t.timestamps
    end
    add_index :pages, [:created_by, :category_id, :meta_id]
  end
end
