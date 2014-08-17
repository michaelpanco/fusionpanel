class AddFullnameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fullname, :string, :after => :username
  end
end
