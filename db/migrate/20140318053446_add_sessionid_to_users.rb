class AddSessionidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :session_id, :string, :limit=>64, :after => :password_salt
  end
end
