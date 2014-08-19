class Asset < ActiveRecord::Base
  validates :name, :presence => true
  validates :name, :uniqueness => { :message => "has already been taken, Please choose another name." }
  validates :name, length: { in: 1..50 }
  validates :parent, :presence => true
end