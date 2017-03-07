#!/usr/bin/env ruby
require 'twitter'
require 'json'
require 'pry'
require "dotenv"

SECONDS_PER_YEAR = 365*24*60*60
MIN_TIME = Time.now - SECONDS_PER_YEAR

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = TWITTER_CONSUMER_KEY
  config.consumer_secret     = TWITTER_CONSUMER_SECRET
  config.access_token        = TWITTER_ACCESS_TOKEN
  config.access_token_secret = TWITTER_ACCESS_TOKEN_SECRET
end

# @tweets = []

def my_collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  # response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  # puts response.inspect
  response.empty? || response[-1].created_at < MIN_TIME ? collection.flatten : my_collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  my_collect_with_max_id do |max_id|
    options = {count: 200, include_rts: false}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

tweets = []

client.get_all_tweets(ARGV[0]).select{ |tweet| tweet.created_at > MIN_TIME }.each do |tweet|
  # puts tweet
  # binding.pry
  tweets << { :date => tweet.created_at,
              :text_analysis => tweet.text.gsub(/\A(.?@\w+\s+)+/, ""),
              :text => tweet.text.gsub(/^\./, ""),
              :mentions => tweet.user_mentions.collect {|mention| mention.attrs[:screen_name]} }
end

# puts JSON.pretty_generate(tweets)

# f = File.new("data/tweets.json", "w+")
# f.write(JSON.pretty_generate(tweets))
# f.close

puts JSON.pretty_generate(tweets)


# puts tweets.inspect


# [
#   {
#     :data => DATE,
#     :text => TEXT,
#     :score => SCORE,
#     ...
#   },
#   {
#     :data => DATE,
#     :text => TEXT,
#     :score => SCORE,
#     ...
#   },
#   ...
# ]



# puts tweets.inspect


# client.get_all_tweets(ARGV[0]).each do |tweet|
#   puts tweet.text
# end



# client.search("to:@BarackObama miss", result_type: "recent").take(10).each do |tweet|
#   # print tweet.user.name + ", " + tweet.user.location + ": "
#   # puts tweet.text
#   @tweets.push tweet.text
# end
