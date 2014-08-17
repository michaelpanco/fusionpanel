class CreateBlockIps < ActiveRecord::Migration
  def change
    create_table :block_ips do |t|
      t.string :ip, :limit => 15
    end
  end
end
