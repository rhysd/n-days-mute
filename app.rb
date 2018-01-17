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
  pp env['omniauth.auth']
  session[:uid] = env['omniauth.auth']['uid']
  redirect to('/')
end

get '/auth/failure' do
  STDERR.puts 'Failed to redirect on authentication'
end

get '/' do
  'Hello, world!'
end
