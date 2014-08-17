class UserRequest < ActiveRecord::Base
	validates :email, :presence => true
	validates :email, :uniqueness => true
	validates :token, :uniqueness => { :message => "has already been taken, Please try again." }
	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	validates :role, :presence => true
end
