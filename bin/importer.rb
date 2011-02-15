#!/usr/bin/env ruby

$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'importer.rb'

begin
  MusicImporter.new(File.expand_path(ARGV[0])).import  
rescue NonExistantMusicRoot
  puts "Please supply a path to the music"
end

