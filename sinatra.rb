require 'rubygems'
require 'sinatra/base'
require 'lib/player.rb'

class DiscoStu < Sinatra::Base
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
  
  post '/next' do
    if @@player
      @@player.next!
      "Skipped Forwards"
    else
      "Not Started Playing"
    end
  end
  
  post '/prev' do
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
  
  def self.run!(options={})
    set options
    handler      = detect_rack_handler
    handler_name = handler.name.gsub(/.*::/, '')
    puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
      "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
    handler.run self, :Host => bind, :Port => port do |server|
      trap(:INT) do
        ## Use thins' hard #stop! if available, otherwise just #stop
        @@player.stop
        server.respond_to?(:stop!) ? server.stop! : server.stop
        puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
      end
      set :running, true
    end
  rescue Errno::EADDRINUSE => e
    puts "== Someone is already performing on port #{port}!"
  end
  
end

DiscoStu.run!
