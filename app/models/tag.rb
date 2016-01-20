class Tag < ActiveRecord::Base
  has_many :post_tags
  has_many :posts, through: :post_tags

  def slug
    self.name.downcase.gsub(" ", "-")
  end

  def self.find_by_slug(slug)
    self.all.detect { |tag| tag.slug == slug }
  end
end