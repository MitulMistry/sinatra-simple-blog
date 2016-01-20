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
      #give message, didn't work?
      redirect to '/users/signup'
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
      redirect to '/users/login'
    end
  end

  #logout process
  get '/users/logout' do
    if logged_in?
      session.destroy #log out
      redirect to '/users/login'
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
  post '/posts/new' do

    if !params[:title].empty? && !params[:content].empty?
      @post = Post.new(title: params[:title], content: params[:content], user_id: session[:user_id]) # new rather than create so doesn't have to write to database twice (has to save at the end)
      @post.tag_ids = params[:tag_ids] # set title ids to array of ids from checkboxes

      if !params[:new_tags].empty?
        params[:new_tags].each do |tag_value|
          tag = Tag.create(name: tag_value)
          @post.tags << tag
        end
      end

      @post.save
      redirect to "/posts/#{@post.slug}"
    else
      #give message, didn't work?
      redirect to '/posts/new'
    end
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
        @tags = Tag.all
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

      if !params[:title].empty? && !params[:content].empty?
        post.tag_ids = params[:tag_ids] # set title ids to array of ids from checkboxes

        post.title = params[:title]
        post.content = params[:content]

        if !params[:new_tags].empty?
          params[:new_tags].each do |tag_value|
            tag = Tag.create(name: tag_value)
            post.tags << tag
          end
        end

        post.save
        redirect to "/posts/#{post.slug}"
      else
        #give message, didn't work?
        redirect to "/posts/#{params[:post_slug]}"
      end
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
  end

end