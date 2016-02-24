require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  #homepage - shows all posts
  get '/' do
    @posts = Post.all
    erb :index
  end

  #signup page to create new user
  get '/users/signup' do
    if logged_in?
      redirect to "/users/#{current_user.slug}"
    else
      erb :'users/signup'
    end
  end

  #create new user
  post '/users/signup' do
    if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
      @user = User.create(username: params[:username], email: params[:email], password: params[:password])
      session[:user_id] = @user.id
      redirect to '/'
    else
      erb :'users/signup', locals: {message: "Failed to create new account. Please fill out the fields with valid information."}
    end
  end

  #login page
  get '/users/login' do
    if logged_in?
      redirect to "/users/#{current_user.slug}"
    else
      erb :'users/login'
    end
  end

  #process login request
  post '/users/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password]) #checks if a user was found and authenticates to password digest
      session[:user_id] = user.id
      redirect to "/users/#{current_user.slug}"
    else
      erb :'users/login', locals: {message: "Invalid user or password. Please try again."}
    end
  end

  #logout process
  get '/users/logout' do
    if logged_in?
      session.destroy #log out
      erb :'users/login', locals: {message: "Successfully logged out."}
    else
      redirect to '/'
    end
  end

  #show user's posts
  get '/users/:user_slug' do
    @user = User.find_by_slug(params[:user_slug])
    erb :'users/show_user'
  end

  #create new post
  get '/posts/new' do
    if logged_in?
      @tags = Tag.all
      erb :'posts/create_post'
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
      erb :'posts/create_post', locals: {message: "Invalid input. Please fill out all the fields."}
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
    erb :'posts/show_post'
  end

  #edit specific post if logged in and correct user
  get '/posts/:post_slug/edit' do
    @post = Post.find_by_slug(params[:post_slug])

    if logged_in?
      if @post.user_id == current_user_id
        @tags = Tag.all
        erb :'posts/edit_post'
      else
        erb :'posts/show_post', locals: {message: "You don't have permission to edit this post."}
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
        erb :'posts/show_post', locals: {message: "Invalid input. To edit a post, please fill out the fields with valid data."}
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
        erb :'posts/show_post', locals: {message: "You don't have permission to delete this post."}
      end
    else
      redirect to '/users/login'
    end
  end

  get '/tags' do
    @tags = Tag.all
    erb :'tags/choose_tag'
  end

  get '/tags/:tag_slug' do
    @tag = Tag.find_by_slug(params[:tag_slug])
    erb :'tags/show_tag'
  end

  helpers do
    def logged_in?
      !!session[:user_id] #!! forces boolean
    end

    def current_user
      User.find(session[:user_id])
    end

    def current_user_id
      session[:user_id]
    end
  end

end