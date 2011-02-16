require 'rubygems'
require 'sinatra/base'
require 'player'
require 'library'

ActiveRecord::Base.include_root_in_json = false

class DiscoStu < Sinatra::Base
  VERSION = '0.0.1'
  
  set :static, true
  set :public, File.dirname(__FILE__) + '/static'
  
  @@player = nil
  
  post '/play' do
    if @@player
      @@player.pause
    else
      @@player = Player.new
      @@player.playlist = [ '../tracks/01.mp3', '../tracks/02.mp3', '../tracks/03.mp3', '../tracks/04.mp3',
                            '../tracks/05.mp3', '../tracks/06.mp3', '../tracks/07.mp3', '../tracks/08.mp3',
                            '../tracks/09.mp3', '../tracks/10.mp3', '../tracks/11.mp3' ]
      @@player.change_track 0
      @@player.play
    end
    ""
  end
  
  post '/player/next' do
    if @@player
      @@player.next!
      "Skipped Forwards"
    else
      "Not Started Playing"
    end
  end
  
  post '/player/prev' do
    if @@player
      @@player.prev!
      "Skipped Backwards"
    else
      "Not Started Playing"
    end
  end
  
  post '/stop' do
    if @@player
      @@player.stop 
    end
    ""
  end
  
  get '/meta' do
    if @@player
      "<h2>#{@@player.metadata['artist']} - #{@@player.metadata['album']}</h2><p><em>#{@@player.metadata['title']}</em></p>"
    else
      ""
    end
  end
  
  get '/albums' do
    content_type :json
    Album.search(params).to_json
  end
  
  get '/artists' do
    content_type :json
    Artist.search(params).to_json
  end
  
  get '/genres' do
    content_type :json
    Genre.search(params).to_json
  end
  
  get '/tracks' do
    content_type :json
    Track.search(params).to_json
  end
  
  get '/tracks/:track_id' do
    content_type :json
    Track.find(params[:track_id]).to_json
  end
  
  post '/playlist_items' do
    PlaylistItem.create :track_id => params[:track_id]
  end
  
  get '/playlist_items' do
    PlaylistItem.all.to_json
  end
  
  get '/playlist_items/current' do
    PlaylistItem.first(:current => true).to_json
  end
  
  delete '/playlist_items/:id' do
    PlaylistItem.destroy params[:id]
  end
  
  put '/playlist_items' do # Used for reordering
    # FIXME
  end
  
  delete '/playlist_items' do
    PlaylistItem.destroy_all
  end
  
  def self.run!(options={})
    set options
    handler      = detect_rack_handler
    handler_name = handler.name.gsub(/.*::/, '')
    puts "== Disco Stu (#{DiscoStu::VERSION}) has taken the to the dance floor " +
      "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
    handler.run self, :Host => bind, :Port => port do |server|
      trap(:INT) do
        ## Use thins' hard #stop! if available, otherwise just #stop
        @@player && @@player.stop
        server.respond_to?(:stop!) ? server.stop! : server.stop
        puts "\n== Disco Stu has finished rocking the dance floor" unless handler_name =~/cgi/i
      end
      set :running, true
    end
  rescue Errno::EADDRINUSE => e
    puts "== Someone is already dancing on port #{port}!"
  end
  
end
