require 'rubygems'
require 'taglib2'
require 'sqlite3'

class MusicImporter
  
  def initialize(root)
    raise NonExistantMusicRoot unless File.exist?(root) and File.directory?(root)
    @root = root
  end

  def process_dir(dir)
    Dir.new(dir).each do |d|
      next if d =~ /^\./
      fullpath = File.join dir, d
    
      if File.directory?(fullpath)
        process_dir(fullpath)
      elsif File.file?(fullpath)
        import_file(fullpath)
      end
    end
  end

  def import_file(file)
    tags = TagLib2::File.new(file)
    
    puts "IMPORTING #{tags.artist}/#{tags.album} - #{tags.title}"
    
    genre_id = get_genre(tags.genre)
    artist_id = get_artist(tags.artist)
    album_id = get_album(artist_id, tags.album)
    
    add_track tags, artist_id, album_id, genre_id
  end
  
  def get_genre(genre)
    return @last_genre[0] if @last_genre && genre == @last_genre[1]
    
    if genre_id = @db.get_first_value("SELECT id FROM genres WHERE genre = ?", genre)
      @last_genre = [ genre_id, genre ]
    else
      @db.execute "INSERT INTO genres (genre) VALUES (?)", genre
      @last_genre = [ @db.last_insert_row_id, genre ]
    end
    @last_genre[0]
  end
  
  def get_artist(artist)
    return @last_artist[0] if @last_artist && @last_artist[1] == artist
    
    if artist_id = @db.get_first_value("SELECT id FROM artists WHERE artist = ?", artist)
      @last_artist = [ artist_id, artist ]
    else
      @db.execute "INSERT INTO artists (artist) VALUES (?)", artist
      @last_artist = [ @db.last_insert_row_id, artist ]
    end
    @last_artist[0]
  end
  
  def get_album(artist_id, album)
    return @last_album[0] if @last_album && @last_album[1] == artist_id && @last_album[2] == album
    
    if album_id = @db.get_first_value("SELECT id FROM albums WHERE artist_id = ? AND album = ?", artist_id, album)
      @last_album = [ album_id, artist_id, album ]
    else
      @db.execute "INSERT INTO albums (artist_id, album) VALUES (?, ?)", artist_id, album
      @last_album = [ @db.last_insert_row_id, artist_id, album ]
    end
    @last_album[0]
  end
  
  def add_track(tags, artist_id, album_id, genre_id)
    sql = "INSERT INTO tracks (track_number, artist_id, album_id, title, genre_id, length) "
    sql << "VALUES (?, ?, ?, ?, ?, ?)"
    @db.execute sql, tags.track, artist_id, album_id, tags.title, genre_id, tags.length
  end

  def truncate_tables
    @db.execute("DELETE FROM artists")
    @db.execute("DELETE FROM albums")
    @db.execute("DELETE FROM genres")
    @db.execute("DELETE FROM tracks")
  end
  
  def import
    connect_to_db
    truncate_tables
    process_dir(@root)
  end
  
  def connect_to_db
    @db = SQLite3::Database.new('db/music.sqlite3')
  end
  
  def albums
    @albums ||= {}
  end
  
  def genres
    @genres ||= []
  end

end

class NonExistantMusicRoot < RuntimeError; end

begin
  MusicImporter.new(File.expand_path(ARGV[0])).import  
rescue NonExistantMusicRoot
  puts "Please supply a path to the music"
end
