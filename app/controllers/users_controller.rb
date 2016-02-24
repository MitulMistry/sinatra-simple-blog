class UsersController < ApplicationController
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
    erb :'users/show'
  end
end