require 'pp'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-twitter'

CONSUMER_KEY=ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET=ENV['TWITTER_CONSUMER_SECRET']

abort 'Twitter consumer key or secret is empty' unless CONSUMER_KEY && CONSUMER_SECRET

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

before do
  pass if request.path_info =~ /^\/auth\//
  redirect to('/auth/twitter') unless current_user
end

get '/auth/twitter/callback' do
  auth = env['omniauth.auth']
  pp auth
  session[:uid] = auth['uid']
  session[:screen_name] = auth['info']['nickname']
  session[:user_name] = auth['info']['name']
  session[:token] = auth['credentials']['token']
  session[:secret] = auth['credentials']['secret']
  redirect to('/')
end

get '/auth/failure' do
  redirect to('/auth_failed.html')
end

get '/beta_only.html' do
end

get '/auth_failed.html' do
end

get '/' do
  return redirect to('/beta_only.html') unless session[:uid] == '119789510'
  "Hello, #{session[:screen_name]} (#{session[:user_name]})"
end
