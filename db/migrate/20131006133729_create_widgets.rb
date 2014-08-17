class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
		t.string :title
		t.string :slug
		t.text :content
		t.integer :created_by
		t.string :status
		t.timestamps
    end
  end
end
