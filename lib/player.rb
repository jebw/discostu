require 'glib2'
require 'gst'

class Player
  @metadata = {}
  
  attr_reader :metadata, :error
  
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
    Thread.new do
      @loop = GLib::MainLoop.new(nil, false)
      @pipeline.play
      @loop.run
    end
  end
  
  def stop
    @loop.quit
    @pipeline.stop
  end
  
  def pause
    @pipeline.pause
  end
  
end