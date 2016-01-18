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
=begin
    if (params are good)

    else
      #give message, didn't work?
    end
=end
    redirect to '/'
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
      redirect to '/users/login'
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
      erb :'posts/create_post'
    else
      redirect to '/users/login'
    end
  end

  #process post creation
  post '/posts/new' do
=begin
    if (params are good)

    else
      #give message, didn't work?
    end
=end
    #redirect to "/posts/#{post.slug}"
  end

  #show specific post based on title slug
  get '/posts/:post_slug' do
    @post = Post.find_by_slug(params[:post_slug])
    erb :'posts/show_post'
  end

  #edit specific post if logged in and correct user
  get '/posts/:post_slug/edit' do
    @post = Post.find_by_slug(params[:post_slug])
    if logged_in?
      if @post.user_id == current_user.id
        erb :'posts/edit_post'
      else
        #give message, you don't have permission?
        redirect to "/posts/#{@post.slug}"
      end
    else
      redirect to '/users/login'
    end
  end

  post '/posts/:post_slug/edit' do
    post = Post.find_by_slug(params[:post_slug])
    if logged_in? && post.user_id == current_user.id
      #if params are good
        #update post with params
      #end
    end
    #redirect to "/posts/#{post.slug}"
  end

  post '/posts/:post_slug/delete' do
    post = Post.find_by_slug(params[:post_slug])
    if logged_in?
      if post.user_id == current_user.id
        post.delete
        #give message, post deleted?
        redirect to '/'
      else
        #give message, you don't have permission?
        redirect to "/posts/#{post.slug}"
      end
    else
      redirect to '/users/login'
    end
  end

  helpers do
    def logged_in?
      !!session[:user_id] #!! forces boolean
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end