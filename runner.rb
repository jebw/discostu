$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'player.rb'


p = Player.new
p.playlist = [ '../tracks/01.mp3', '../tracks/02.mp3', '../tracks/03.mp3' ]
p.change_track 0

p.play

sleep(5)

p.stop

sleep(5)

p.play

sleep(5)

p.stop

puts p.metadata.inspect
