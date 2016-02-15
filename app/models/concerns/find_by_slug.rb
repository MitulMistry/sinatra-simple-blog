module FindBySlug
  def find_by_slug(slug)
    self.all.detect { |item| item.slug == slug }
  end
end