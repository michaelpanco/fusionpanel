class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.string :activity_type, :limit => 32
      t.string :activity_message, :limit => 255
      t.datetime :created_at
    end
  end
end
