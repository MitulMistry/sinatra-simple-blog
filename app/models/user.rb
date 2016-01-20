class User < ActiveRecord::Base
  has_many :posts
  has_secure_password

  def slug
    self.username.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    self.all.detect { |user| user.slug == slug }
  end
end