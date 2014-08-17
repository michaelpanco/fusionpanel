class ModifyTrafficTable < ActiveRecord::Migration
  def change
    remove_column :traffics, :page_id, :integer
    add_column :traffics, :url, :string, :after => :ip
  end
end
