class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_tags
  has_many :tags, through: :post_tags

  extend FindBySlug

  def slug
    self.title.downcase.gsub(" ", "-")
  end

  def readable_date
    self.created_at.strftime("%b %d, %Y")
  end
end