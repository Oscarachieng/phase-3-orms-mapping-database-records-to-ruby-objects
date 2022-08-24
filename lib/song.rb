class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end
# a class method to convert the returned data from the database
  def self.new_from_db (row)
    self.new(id: row[0], name: row[1], album: row[2])
  end
  # class method to get all songs from the database
  def self.all 
    my_songs = DB[:conn].execute("SELECT * FROM songs")
    my_songs.map do |song_row|
      self.new_from_db(song_row)
    end
  end
  #cclass method to find a song by name
  def self.find_song_by_name (name)
    my_song = DB[:conn].execute("SELECT * FROM songs WHERE name IS ? LIMIT 1", name)
    my_song.map do |this_very_song|
      self.new_from_db(this_very_song)
    end
  end
end
