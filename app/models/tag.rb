class Tag < ActiveRecord::Base
  has_many :post_tags
  has_many :posts, through: :post_tags

  extend FindBySlug
  
  def slug
    self.name.downcase.gsub(" ", "-")
  end

  def self.delete_empty_tags
    self.all.each do |tag|
      tag.destroy if tag.posts.count == 0 || tag.posts.count == nil
    end
  end
end