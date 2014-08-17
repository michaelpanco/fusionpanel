class AddAuthenticationTokenFromUser < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string, :limit => 64, :after => :password_salt
  end
end
