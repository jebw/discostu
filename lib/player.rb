require 'glib2'
require 'gst'

class Player
  NOT_STARTED = 0
  PLAYING = 1
  PAUSED = 2
  STOPPED = 3
  
  @metadata = {}
  @status = NOT_STARTED
  
  attr_reader :metadata, :error, :status
  
  def initialize(filename = nil)
    change_track filename if filename
  end
  
  def change_track(filename)
    @error = nil
    @metadata = {}
    
    @pipeline = Gst::Pipeline.new
    playbin = Gst::ElementFactory.make('playbin')
    playbin.uri = "file://#{File.expand_path(filename)}"
    @pipeline.add playbin
    
    @pipeline.bus.add_watch do |bus, message|
      case message.type
      when Gst::Message::EOS
        @loop.quit
        @pipeline.stop
      when Gst::Message::ERROR
        @error = message.parse
        @loop.quit
        @pipeline.stop
      when Gst::Message::TAG
        message.parse.each do |tag|
          @metadata[tag[0]] = tag[1]
        end
      end
      true
    end
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
    @pipeline.stop
    @stop = STOPPED
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
  
end