class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_tags
  has_many :tags, through: :post_tags
  
  def slug
    self.title.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    self.all.detect { |post| post.slug == slug }
  end
end