#!/usr/bin/env ruby1.9.3

#select solarSystemID, solarSystemName from mapSolarSystems;

require 'sqlite3'
require 'yaml'

db = SQLite3::Database.new "../data/universeDataDx.db"

a = []

rows = db.execute("SELECT solarSystemID, solarSystemName from mapSolarSystems") do |row|
	d = { }
	d[:systemId] = row[0]
	d[:name] = row[1]
	a.push d
end

print a.to_yaml
