require 'tty-prompt'
require 'open-uri'
require 'net/http'
require 'json'
require 'sqlite3'
require_relative '../config/environment.rb'

class Article
@@all = []
@@npage = 1
PR = TTY::Prompt.new
DB = SQLite3::Database.open "db/articles.db"
API_KEY = ENV["API_NEWS_KEY"]    
@@url = "https://newsdata.io/api/1/news?apikey=#{API_KEY}&language=en&page=1"


attr_reader :title, :description, :link, :pubDate
attr_accessor :id

    def initialize(id = nil, title, description, link, pubDate)
        @id = id
        @title = title
        @description = description
        @link = link
        @pubDate = pubDate
    end

    def self.showall
        puts @@all.size
    end

    def self.get_news
    uri = URI.parse(@@url)
    response = Net::HTTP.get_response(uri)
    programs = JSON.parse(response.body)["results"]
    programs.collect do |program|
        
        date = Date.strptime(program['pubDate'], '%Y-%m-%d')
        programdate = date.strftime('%d-%m-%Y')
        @@all << [program['title'], program['description'],program['content'],program['link'],programdate] 
        end
    end

    def self.drop_table
        DB.execute("DROP TABLE articles_table")
        puts 'table is deleted'
    end

    def self.create_table
        sql =  <<-SQL 
        CREATE TABLE IF NOT EXISTS articles_table (
          id INTEGER PRIMARY KEY, 
          title TEXT, 
          description TEXT,
          content TEXT,
          link TEXT,
          programdate TEXT)
        SQL
        DB.execute(sql)
    end

    def self.create_instance
        @@all.each do |art|
            news = Article.new(art[0],art[1],art[2],art[3],art[4])
        end
    end

    def self.insert_data
        @@all.each do |art|
            sql = <<-SQL
            INSERT INTO articles_table (title, description, content, link, programdate) 
            VALUES(?, ?, ?, ?, ?)
            SQL
            DB.execute(sql, art[0],art[1],art[2],art[3],art[4])
        @id = DB.execute("SELECT last_insert_rowid() FROM articles_table")
        end
        puts 'data insert in the database'
    end

    def self.queryall
        sql = <<-SQL
        SELECT id, title, description 
        FROM articles_table
        SQL
        result = DB.execute(sql)
        puts result
    end

    def self.select(id)
        sql = <<-SQL
        SELECT content, link, programdate
        FROM articles_table
        WHERE id = ?
        SQL
        result = DB.execute(sql, id)
        puts result
    end


    def self.prestart
        Article.create_table
        Article.get_news
        Article.create_instance
        Article.insert_data
    end

    def self.start
        puts "
        ======================================================================
        Welcome to direct NEWS app CLI
        This is my application which is fetching the lastest and freshest NEWS 
        You can see on internet
        Here are all the fresh NEWS.
        Type 'enter' if you want to fetch them
        ======================================================================
        " 
        enter = PR.ask("
        ...
        ")
        if enter == 'enter' 
            self.queryall
        else
            puts "
            =============================================
            ... ok you didnt type 'enter'
            =============================================
            "
            sleep(3)
            puts "
            =============================================
            last chance for you, type 'enter' and you'll
            get all the NEWS
            =============================================
            "
            sleep(4)
            self.start
        end
        self.askwhichid
        
    end

     def self.queryselected(id)
         puts "
         =============================================
         You have selected the id #{id}
         =============================================
         "
         sleep(2)
         self.select(id)
     end

     def self.askwhichid
        puts "
        =============================================
        Type the ID of the new you would like to see
        And press ENTER
        =============================================
        "
        ##### next page  function to do 
        enter = PR.ask("
        ...
         ")
         sleep(2)
        # if enter == 'next'
        #   puts `clear`
        # self.drop_table
           

        # else
        self.queryselected(enter)
        self.returnlist
        # end
     end

     def self.returnlist
        puts "
        =============================================
        Type 'back' and press ENTER to go back to the Initial 
        list of fresh News
        =============================================
        "
        enter = PR.ask("
        ...
        ")
        if enter == 'back'
        sleep(2)
        self.queryall
        self.askwhichid
        else 
            puts "
            =============================================
            Mistake ... type 'back'
            =============================================
            "
            self.returnlist
        end
     end

end

