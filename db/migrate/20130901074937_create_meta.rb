class CreateMeta < ActiveRecord::Migration
  def change
    create_table :meta do |t|
		t.string :page_title
		t.string :page_description
		t.string :page_keywords
		t.boolean :no_index
		t.boolean :no_follow
    end
  end
end
