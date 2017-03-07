#!/usr/bin/env ruby

require "google/cloud/language"
require "json"
require "dotenv"

json = $stdin.read

tweets = JSON.parse(json, :symbolize_names => true)

# Your Google Cloud Platform project ID
project_id = ENV['GOOGLE_PROJECT_ID']

# Instantiates a client
language = Google::Cloud::Language.new project: project_id

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
end

puts JSON.pretty_generate(tweets);
