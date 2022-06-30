require 'bundler'
require 'tty-prompt'
Bundler.require
Dotenv.load("./.env")
require_relative '../lib/article.rb'


DB = {:conn => SQLite3::Database.new("db/articles.db")}
