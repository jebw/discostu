require 'glib2'
require 'gst'

class Player
  NOT_STARTED = 0
  PLAYING = 1
  PAUSED = 2
  STOPPED = 3
  
  @metadata = {}
  @status = NOT_STARTED
  
  @current = nil
  
  attr_reader :metadata, :error, :status, :current
  attr_accessor :playlist
  
  def initialize(filename = nil)
    change_track filename if filename
  end
  
  def change_track(playlist_item)
    @error = nil
    @metadata = {}
    @current = playlist_item
    
    @pipeline = Gst::Pipeline.new
    playbin = Gst::ElementFactory.make('playbin')
    playbin.uri = "file://#{File.expand_path(@current.track.filename)}"
    @pipeline.add playbin
    
    @pipeline.bus.add_watch do |bus, message|
      case message.type
      when Gst::Message::EOS
        if @current < Playlist.max(:position) - 1
          @pipeline.stop
          change_track @current.lower_item
          @pipeline.play
        else
          stop
        end
      when Gst::Message::ERROR
        @error = message.parse
        stop
      when Gst::Message::TAG
        message.parse.each do |tag|
          @metadata[tag[0]] = tag[1]
        end
      end
      true
    end
    rescue ActiveRecord::RecordNotFound
      # Fails silently
  end
  
  def play
    if @status == PAUSED
      @pipeline.play
      @status = PLAYING
    else
      Thread.new do
        @loop = GLib::MainLoop.new(nil, false)
        @pipeline.play
        @status = PLAYING
        @loop.run
      end
    end
  end
  
  def stop
    @loop.quit
    @stop = STOPPED
    @pipeline.stop
  end
  
  def pause
    if @status == PAUSED
      @pipeline.play
      @status = PLAYING
    else
      @pipeline.pause
      @status = PAUSED
    end
  end
  
  def next!
    return false unless next_track = @current.lower_item

    if status == PLAYING
      stop
      change_track next_track
      play
    else
      @pipeline.stop
      change_track next_track
    end
  end
  
  def prev!
    return false unless prev_track = @current.higher_item
    
    if status == PLAYING
      stop
      change_track prev_track
      play
    else
      @pipeline.stop
      change_track prev_track
    end
  end
end