class CreateStatusFromTraffic < ActiveRecord::Migration
  def change
    add_column :traffics, :status, :string, :limit=>3, :after => :browser
  end
end
