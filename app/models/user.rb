class User < ActiveRecord::Base

  has_many :page, :foreign_key => 'created_by'
  belongs_to :role
  has_many :activity

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :crypted_password, presence: true
  validates :crypted_password, confirmation: true

  validates :username, length: { in: 6..20 }, :allow_blank => true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }, :allow_blank => true
  validates :crypted_password, length: { minimum: 8 }, :allow_blank => true

  before_create :encrypt_password
  
  PERMISSION_ERROR_MSG = "You don't have permission to perform this action."
  
  def self.login(username, password)
    user = find(:first, :conditions => ['email = ? or username = ?', username, username])
    if user && user.crypted_password == BCrypt::Engine.hash_secret(password, user.password_salt)
    user
    else
      nil
    end
  end

  def encrypt_password
    if crypted_password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.crypted_password = BCrypt::Engine.hash_secret(crypted_password, password_salt)
    end
  end

  def self.search(query)
    if query
      if User.where('fullname LIKE ?', "%#{query}%").take
        where('fullname LIKE ?', "%#{query}%")
      else
        if User.where('username LIKE ?', "%#{query}%").take
          where('username LIKE ?', "%#{query}%")
        else
          where('email LIKE ?', "%#{query}%")
        end
      end
    else
      all
    end 
  end

  def date_joined
    self.created_at.to_time.strftime('%b %d, %Y')
  end

  def username
    self.read_attribute(:username)
  end

end
