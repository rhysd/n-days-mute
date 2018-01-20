require 'pp'
require 'active_support/core_ext/numeric/time'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'omniauth-twitter'
require 'twitter'
require './models'

CONSUMER_KEY=ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET=ENV['TWITTER_CONSUMER_SECRET']

abort 'Twitter consumer key or secret is empty' unless CONSUMER_KEY && CONSUMER_SECRET

# Establish database connectioin

set :database_file, 'db/database.yml'

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
    user_id: session[:uid],
    user_name: session[:user_name],
    screen_name: session[:screen_name],
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

get '/mute' do
  screen_name = params['screen_name']
  days = params['days'].to_i
  redirect to('/') unless screen_name && days > 0

  tw = Twitter::REST::Client.new do |config|
    config.consumer_key = CONSUMER_KEY
    config.consumer_secret = CONSUMER_SECRET
    config.access_token = session[:token]
    config.access_token_secret = session[:secret]
  end
  muted = tw.mute(screen_name)[0]

  Mute.find_or_initialize_by(user_id: muted.id).update(
    user_id: muted.id,
    screen_name: screen_name,
    days: days,
    muted_by_user_id: session[:uid],
  )

  redirect to('/')
end

get '/' do
  return redirect to('/welcome.html') unless session[:uid]
  return redirect to('/beta_only.html') unless session[:uid] == '119789510'
  @screen_name = session[:screen_name]
  @user_name = session[:user_name]
  @muted = Mute.where(muted_by_user_id: session[:uid])
  erb :index
end
