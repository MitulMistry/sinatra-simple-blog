class PostsController < ApplicationController
  #create new post
  get '/posts/new' do
    if logged_in?
      @tags = Tag.all
      erb :'posts/new'
    else
      redirect to '/users/login'
    end
  end

  #process post creation
  post '/posts' do
    if !params[:post][:title].empty? && !params[:post][:content].empty?
      params[:post][:user_id] = current_user_id #sets user_id for post to current session user rather than having a hidden field in the form
      @post = Post.new(params[:post]) #ActiveRecord handles array of tag_ids from checkboxes

      if !params[:tag][:name].empty?
        @post.tags << Tag.create(name: params[:tag][:name]) #create new tag
      end

      @post.save
      redirect to "/posts/#{@post.slug}"
    else
      @tags = Tag.all
      erb :'posts/new', locals: {message: "Invalid input. Please fill out all the fields."}
    end
  end

  #show specific post based on title slug
  get '/posts/:post_slug' do
    @post = Post.find_by_slug(params[:post_slug])
    if @post.user_id == current_user_id
      @owns_post = true
    else
      @owns_post = false
    end
    erb :'posts/show'
  end

  #edit specific post if logged in and correct user
  get '/posts/:post_slug/edit' do
    @post = Post.find_by_slug(params[:post_slug])

    if logged_in?
      if @post.user_id == current_user_id
        @tags = Tag.all
        erb :'posts/edit'
      else
        erb :'posts/show', locals: {message: "You don't have permission to edit this post."}
      end
    else
      redirect to '/users/login'
    end
  end

  #process post edit
  post '/posts/:post_slug' do
    @post = Post.find_by_slug(params[:post_slug])

    if logged_in? && @post.user_id == current_user_id

      if !params[:post][:title].empty? && !params[:post][:content].empty?
        params[:post][:user_id] = current_user_id
        @post.update(params[:post])

        if !params[:tag][:name].empty?
          @post.tags << Tag.create(name: params[:tag][:name])
        end

        @post.save
        Tag.delete_empty_tags
        redirect to "/posts/#{@post.slug}"
      else
        erb :'posts/show', locals: {message: "Invalid input. To edit a post, please fill out the fields with valid data."}
      end
    end
  end

  #process post deletion
  post '/posts/:post_slug/delete' do
    @post = Post.find_by_slug(params[:post_slug])
    if logged_in?
      if @post.user_id == current_user_id
        @post.destroy
        Tag.delete_empty_tags

        @posts = Post.all
        erb :'index', locals: {message: "Post deleted."}
      else
        erb :'posts/show', locals: {message: "You don't have permission to delete this post."}
      end
    else
      redirect to '/users/login'
    end
  end
end