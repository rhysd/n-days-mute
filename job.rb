require 'active_record'
require 'active_support/core_ext/numeric/time'
require './models'

CONSUMER_KEY=ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET=ENV['TWITTER_CONSUMER_SECRET']

abort 'Twitter consumer key or secret is empty' unless CONSUMER_KEY && CONSUMER_SECRET

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'data.sqlite3')

now = Time.now
User.all.each do |muter|
  muter_name = muter['screen_name']
  muter_id = muter['user_id']
  puts "User @#{muter_name}(#{muter_id})"
  client = nil

  Mute.where(muted_by_user_id: muter_id).each do |mutee|
    mutee_name = mutee['screen_name']
    unmuted_at = mutee['updated_at'] + mutee['days'].days
    unless now > unmuted_at
      puts "Skip @#{mutee_name}, not exceeding #{unmuted_at}"
      next
    end

    puts "Will unmute @#{mutee_name} by @#{muter_name} (Exceeded #{unmuted_at})"

    client = client || Twitter::REST::Client.new do |config|
      config.consumer_key = CONSUMER_KEY
      config.consumer_secret = CONSUMER_SECRET
      config.access_token = muter['token']
      config.access_token_secret = muter['secret']
    end

    begin
      unmuted = client.unmute(screen_name)
      puts "Successfully unmuted #{unmuted} by @#{muter_name}"
    rescue => err
      if err.message.include? 'You are not muting the specified user.'
        puts "User is not muted."
      else
        STDERR.puts "Error! #{err}. Give up unmuting"
      end
    end

    mutee.destroy
  end
end
