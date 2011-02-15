require 'rubygems'
require 'taglib2'
require 'library'

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
    
    genre = get_genre(tags.genre)
    artist = get_artist(tags.artist)
    album = get_album(artist, tags.album, tags.year)
    
    add_track tags, artist, album, genre
  
  rescue TagLib2::BadFile
    puts "UNABLE TO READ TAGS FROM '#{file}'"
  end
  
  def get_genre(genre)
    return @last_genre if @last_genre && genre == @last_genre.name
    @last_genre = Genre.find_or_create_by_name(genre)
  end
  
  def get_artist(artist)
    return @last_artist if @last_artist && @last_artist.name == artist
    @last_artist = Artist.find_or_create_by_name(artist)
  end
  
  def get_album(artist, album, year = nil)
    return @last_album if @last_album && @last_album.artist_id == artist.id && @last_album.name == album
    @last_album = Album.find_by_artist_id_and_name(artist.id, album) || 
                  Album.create(:artist => artist, :name => album, :year => year)
  end
  
  def add_track(tags, artist, album, genre)
    t = Track.create! :artist => artist, :album => album, :genre => genre, :track_no => tags.track, 
                      :title => tags.title, :length => tags.length
  rescue ActiveRecord::RecordInvalid
    puts "COULD NOT INSERT #{t.inspect}"
  end

  def truncate_tables
    db_execute("DELETE FROM artists")
    db_execute("DELETE FROM albums")
    db_execute("DELETE FROM genres")
    db_execute("DELETE FROM tracks")
  end
  
  def import
    truncate_tables
    process_dir(@root)
  end
    
  def db_execute(*params)
    ActiveRecord::Base.connection.execute *params
  rescue SQLite3::SQLException
    puts "ERROR IMPORTING - UNKNOWN WHY"
#    puts "RESCUING AND RETRYING"
#    @db = SQLite3::Database.new File.expand_path('db/music.sqlite3')
#    @db.execute *params
  end
  
  def albums
    @albums ||= {}
  end
  
  def genres
    @genres ||= []
  end

end

class NonExistantMusicRoot < RuntimeError; end
