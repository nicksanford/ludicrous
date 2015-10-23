unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load 
end
require './app'
require './config/octokit'
run App
