require 'pp'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'omniauth-twitter'
require './models/user'

CONSUMER_KEY=ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET=ENV['TWITTER_CONSUMER_SECRET']

abort 'Twitter consumer key or secret is empty' unless CONSUMER_KEY && CONSUMER_SECRET

set :database, {adapter: 'sqlite3', database: 'data.sqlite3'}

# Authenticate with Twitter account
# http://recipes.sinatrarb.com/p/middleware/twitter_authentication_with_omniauth

configure do
  enable :sessions

  use OmniAuth::Builder do
    provider :twitter, CONSUMER_KEY, CONSUMER_SECRET
  end
end

helpers do
  def current_user
    !session[:uid].nil?
  end
end

get '/auth/twitter/callback' do
  auth = env['omniauth.auth']

  session[:uid] = auth['uid']
  session[:screen_name] = auth['info']['nickname']
  session[:user_name] = auth['info']['name']
  session[:token] = auth['credentials']['token']
  session[:secret] = auth['credentials']['secret']

  User.find_or_initialize_by(user_id: session[:uid]).update(
    screen_name: session[:screen_name],
    user_name: session[:user_name],
    token: session[:token],
    secret: session[:secret],
  )

  redirect to('/')
end

get '/auth/failure' do
  redirect to('/auth_failed.html')
end

get '/beta_only.html' do
end

get '/auth_failed.html' do
end

get '/welcome.html' do
end

get '/' do
  return redirect to('/welcome.html') unless session[:uid]
  return redirect to('/beta_only.html') unless session[:uid] == '119789510'
  @screen_name = session[:screen_name]
  @user_name = session[:user_name]
  erb :index
end
