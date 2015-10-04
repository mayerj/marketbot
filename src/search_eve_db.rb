#!/usr/bin/env ruby1.9.3

require './lib/evedb'

db = EveDb.new '../data/typeIDs.yaml'

toFind = ARGV[0]

p =  db.find(toFind)

p.each do |typeId|
	name = db.get_name typeId
	print "#{name}\r\n"
end
