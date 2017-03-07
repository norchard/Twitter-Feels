#!/usr/bin/env ruby

require 'twitter'
require 'json'
require 'pry'
require "dotenv"

SECONDS_PER_YEAR = 365*24*60*60
MIN_TIME = Time.now - SECONDS_PER_YEAR

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

def my_collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
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
  tweets << { :date => tweet.created_at,
              :text_analysis => tweet.text.gsub(/\A(.?@\w+\s+)+/, ""),
              :text => tweet.text.gsub(/^\./, ""),
              :mentions => tweet.user_mentions.collect {|mention| mention.attrs[:screen_name]} }
end

puts JSON.pretty_generate(tweets)
