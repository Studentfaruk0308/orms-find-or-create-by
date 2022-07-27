require 'sqlite3'

DB = {:conn => SQLite3::Database.new("/home/faruk/Development/Code/Phase-3/orms-find-or-create-by/songs.db")}

class Song

    attr_accessor :name, :album
    attr_reader :id
      
      def initialize(id=nil, name, album)
        @id = id
        @name = name
        @album = album
      end
    
      def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS songs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            album TEXT
            )
            SQL
        DB[:conn].execute(sql)
      end

      def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO songs (name, album)
            VALUES (?, ?)
          SQL
    
          DB[:conn].execute(sql, self.name, self.album)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
        end
      end
    
      def self.create(name:, album:)
        song = Song.new(name, album)
        song.save
        song
      end
      
      def self.find_by_id(id)
        sql = "SELECT * FROM songs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Song.new(result[0], result[1], result[2])
      end
      
      def update
        sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.album, self.id)
      end

      def self.find_or_create_by(name:, album:)
        song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
        if !song.empty?
          song_data = song[0]
          song = Song.new(song_data[0], song_data[1], song_data[2])
        else
          song = self.create(name: name, album: album)
        end
        song
      end

    end

    # Song.create_table
    Song.find_or_create_by(name: "Hello1", album: "26")
    # Song.find_or_create_by(name: "Hello", album: "25")

# DB[:conn].execute("SELECT * FROM songs WHERE name = Hello, album = 25")

   


    
