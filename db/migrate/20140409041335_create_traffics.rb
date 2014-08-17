class CreateTraffics < ActiveRecord::Migration
  def change
    create_table :traffics do |t|
      t.string :ip, :limit => 20
      t.integer :page_id
      t.string :browser, :limit => 512
      t.datetime :created_at
    end
  end
end
