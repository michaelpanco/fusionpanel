class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
			t.string :email
			t.string :username
			t.string :crypted_password
			t.string :reset_password_token
      t.timestamps
    end
  end
end
