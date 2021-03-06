require 'rubygems'
require 'active_record'
require 'acts_as_list'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::List }

begin
  ActiveRecord::Base.connection
rescue ActiveRecord::ConnectionNotEstablished 
  dbpath = File.expand_path File.join(File.dirname(__FILE__), '..', 'db', 'music.sqlite3')
#  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', 
#                                          :database => dbpath, 
#                                          :encoding => 'utf8'
  ActiveRecord::Base.establish_connection :adapter => 'mysql', :database => 'disco_stu', :username => 'jebw', :password => '', :host => 'localhost'
end

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate File.join(File.dirname(__FILE__), '..', 'db', 'migrate')

class Artist < ActiveRecord::Base
  validates_presence_of :name
  has_many :albums, :order => :year
  has_many :tracks, :order => :title
  
  def self.search(options = {})
    (options['name'] ? where('name LIKE ?', "%#{options['name']}%") : self).all
  end
end

class Album < ActiveRecord::Base
  validates_presence_of :name, :artist
  belongs_to :artist
  has_many :tracks, :order => :track_no
  
  def self.search(options = {})
    albums = self
    albums = albums.where :artist_id => options['artist_id'] if options['artist_id']
    albums = albums.where "name LIKE ?", "%#{options['name']}%" if options['name']
    albums.all
  end
end

class Track < ActiveRecord::Base
  validates_presence_of :title, :track_no, :artist, :album
  validates_uniqueness_of :track_no, :scope => :album_id
  belongs_to :album
  belongs_to :artist
  belongs_to :genre
  has_many :playlist_items, :order => :position
  
  def self.search(options = {})
    tracks = self
    tracks = tracks.where :artist_id => options['artist_id'] if options['artist_id']
    tracks = tracks.where :album_id => options['album_id'] if options['album_id']
    tracks = tracks.where :genre_id => options['genre_id'] if options['genre_id']
    tracks = tracks.includes(:genre).where 'genres.name LIKE ?', "%#{options['genre']}%" if options['genre']
    tracks = tracks.includes(:artist).where 'artists.name LIKE ?', "%#{options['artist']}%" if options['artist']
    tracks = tracks.includes(:album).where 'albums.name LIKE ?', "%#{options['album']}%" if options['album']
    tracks = tracks.where 'title LIKE ?', "%#{options[:title]}%" if options['title']
    tracks.all
  end
end

class Genre < ActiveRecord::Base
  validates_presence_of :name
  has_many :tracks
  
  def self.search(options = {})
    (options['name'] ? where('name LIKE ?', "%#{options['name']}%") : self).all
  end
end

class PlaylistItem < ActiveRecord::Base
  acts_as_list
  
  validates_presence_of :track
  belongs_to :track
  default_scope :order => :position
  
  class << self
  
    def create_multiple(track_ids)
      track_ids.each { |t_id| create :track_id => t_id }
    end
  
    def add_album(album_id)
      Track.find_all_by_album_id(album_id).each {|track| create :track => track }
    end
    
  end
end
