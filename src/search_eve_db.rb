#!/usr/bin/env ruby1.9.3

require './lib/evedb'

db = EveDb.new '../data/typeIDs.yaml'

toFind = ARGV[0]

p toFind

pp =  db.find(toFind)

pp.each do |typeId|
	name = db.get_name typeId
	print "#{name}\r\n"
end
