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