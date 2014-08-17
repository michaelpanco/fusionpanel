class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
		t.string :name
		t.string :permissions
		t.string :status
    end
  end
end
