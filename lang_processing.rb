#!/usr/bin/env ruby

# Imports the Google Cloud client library
require "google/cloud/language"
require "json"
require "dotenv"

# f = open("tweets", "r+")
# json = f.read
# f.close

json = $stdin.read

tweets = JSON.parse(json, :symbolize_names => true)

# puts tweets[0][:text]

# Your Google Cloud Platform project ID
project_id = ENV['GOOGLE_PROJECT_ID']

# Instantiates a client
language = Google::Cloud::Language.new project: project_id

# # The text to analyze
# text     = "I'm hungry. Let's eat breakfast."
# document = language.document text
#
# # Detects the sentiment of the text
# sentiment = document.sentiment
#
# puts "Text: #{text}"
# puts "Score: #{sentiment.score}, #{sentiment.magnitude}"

# count = 0
# score = 0
# magnitude = 0

tweets.each do |tweet|
  $stderr.print "."
  text     = tweet[:text_analysis]
  document = language.document text, language: "en"
  document.language
  sentiment = document.sentiment
  tweet[:score] = sentiment.score
  tweet[:mag] = sentiment.magnitude
  tweet[:nouns] = []

  syntax = document.syntax
  syntax.tokens.each {|token| tweet[:nouns] << token.text.downcase if token.part_of_speech.tag.to_s == "NOUN"}

  # count += 1
  # score += sentiment.score
  # magnitude += sentiment.magnitude

  # puts "Text: #{text}"
  # puts "Score: #{sentiment.score}, #{sentiment.magnitude}"
end

# f = File.new("data/tweet_feels.json", "w+")
# f.write(JSON.pretty_generate(tweets));
# f.close

puts JSON.pretty_generate(tweets);

# puts "Average score: #{score / count}"
# puts "Average magnitude: #{magnitude / count}"
