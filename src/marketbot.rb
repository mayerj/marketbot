#!/usr/bin/env ruby1.9.3

require 'yaml'

api_key = YAML.load_file(ARGV[0])

require "rubygems"
require "slack-ruby-client"
require "./lib/parser"
require "./lib/evedb"

Slack.configure do |config|
  config.token = api_key
end

web = Slack::Web::Client.new

print web.auth_test

client = Slack::RealTime::Client.new

client.on :hello do
	puts 'connected'
end

eve_db = EveDb.new "data/universeDataDx.db"
system_db = SystemDb.new "data/systemIds.yaml"

client.on :message do |data|
	if data['user'] != client.self['id']
	
		begin
			parser = Parser.new eve_db, system_db, client, data
			parser.handle

		rescue Exception => e
			print "Exception #{e}\r\n#{e.backtrace}\r\n"
		end
	end	#client.message channel: data['channel'], text: "hi!"
end

client.start!

