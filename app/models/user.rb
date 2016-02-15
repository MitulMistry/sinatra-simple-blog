class User < ActiveRecord::Base
  has_many :posts
  has_secure_password

  extend FindBySlug
  
  def slug
    self.username.downcase.gsub(" ", "-")
  end
end