$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'player.rb'

playlist = [ '01.mp3', '02.mp3', '03.mp3', '04.mp3' ]

p = Player.new
p.change_track "../tracks/01.mp3"
p.play

puts "NOW PLAYING"

sleep(2)

puts p.status

p.pause

puts p.status

sleep(3)

puts p.pause

puts p.status

sleep(2)

puts p.status

p.pause

puts p.status

sleep(2)

p.play

puts p.status

sleep(10)

p.stop

puts "STOPPED PLAYING"

puts p.metadata.inspect
