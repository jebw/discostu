require 'rubygems'
require 'active_record'

begin
  ActiveRecord::Base.connection
rescue ActiveRecord::ConnectionNotEstablished 
  dbpath = File.expand_path File.join(File.dirname(__FILE__), '..', 'db', 'music.sqlite3')
  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', 
                                          :database => dbpath, 
                                          :encoding => 'utf8'
end

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate File.join(File.dirname(__FILE__), '..', 'db', 'migrate')

class Artist < ActiveRecord::Base
  validates_presence_of :name
  has_many :albums, :order => :year
  has_many :tracks, :order => :title
end

class Album < ActiveRecord::Base
  validates_presence_of :name, :artist
  belongs_to :artist
  has_many :tracks, :order => :track_no
end

class Track < ActiveRecord::Base
  validates_presence_of :title, :track_no, :artist, :album
  validates_uniqueness_of :track_no, :scope => :album_id
  belongs_to :album
  belongs_to :artist
  belongs_to :genre
  has_many :playlist_items, :order => :position
end

class Genre < ActiveRecord::Base
  validates_presence_of :name
  has_many :tracks
end

class PlaylistItem < ActiveRecord::Base
  validates_presence_of :track
  belongs_to :track
  default_scope :order => :position
end
