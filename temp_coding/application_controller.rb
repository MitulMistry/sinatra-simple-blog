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

    erb :index
  end

  #signup page to create new user
  get '/users/signup' do

    erb :'users/signup'
  end

  #login page
  get '/users/login' do

    erb :'users/login'
  end

  #show user's posts
  get '/users/:user_slug' do

    erb :'users/show_user'
  end

  #create new post
  get '/posts/new' do

    erb :'posts/create_post'
  end

  #show specific post based on title slug
  get '/posts/:post_slug' do

    erb :'posts/show_post'
  end

  #edit specific post if logged in and correct user
  get '/posts/:post_slug/edit' do

    erb :'posts/edit_post'
  end


end