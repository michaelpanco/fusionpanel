class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :setting_name, :limit => 64
      t.text :setting_value, :limit => 4294967295
    end
  end
end
