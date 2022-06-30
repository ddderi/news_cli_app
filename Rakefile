namespace :db do
    task :console => :environment do
        Pry.start
        end

    task :migrate => :environment do
        Article.prestart
        puts "table created"
    end

    task :environment do 
        require_relative './config/environment.rb'
    end
    

    desc 'start the app'
    task :start => :environment do 
        Article.start
    end
end