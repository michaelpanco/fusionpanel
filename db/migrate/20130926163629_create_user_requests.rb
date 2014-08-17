class CreateUserRequests < ActiveRecord::Migration
  def change
    create_table :user_requests do |t|
		t.string :email
		t.string :role
		t.string :token
		t.string :status
		t.timestamps
    end
  end
end
