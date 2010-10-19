$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'player.rb'


p = Player.new
p.playlist = [ '../tracks/01.mp3', '../tracks/02.mp3', '../tracks/03.mp3' ]
p.change_track 0

p.play

sleep(5)

p.next!

sleep(5)

p.pause

puts 'PAUSED'

p.next!

puts "SHOULD STILL BE PAUSED"
sleep(3)

p.play

puts "NOW PLAYING"

sleep(5)

p.prev!

puts "SHOULD BE BACK TO PREVIPOS TRACK"

sleep(10)

p.stop


puts "STOPPED PLAYING"

sleep(3)

puts "NOW ENDING"

puts p.metadata.inspect
