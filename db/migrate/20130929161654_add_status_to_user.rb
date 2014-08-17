class AddStatusToUser < ActiveRecord::Migration
  def change
    add_column :users, :status, :string, :after => :reset_password_token
  end
end
