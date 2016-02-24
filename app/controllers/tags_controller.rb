class TagsController < ApplicationController
  get '/tags' do
    @tags = Tag.all
    erb :'tags/index'
  end

  get '/tags/:tag_slug' do
    @tag = Tag.find_by_slug(params[:tag_slug])
    erb :'tags/show'
  end
end