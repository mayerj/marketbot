require 'net/http'
require 'nokogiri'
require './lib/evecentral'
require './lib/command'

class Parser
	def initialize(eve_db, systems, client, data)
		@eve_db = eve_db
		@systems_db = systems
		@client = client
		@data = data
	end

	def handle()
		command = extract_command(@data['text'])

		if command.nil?
			return
		end

		case command.command
			when 'price' then
				process_price_request_jita(command)
			when 'pricesystem' then
				process_price_request_system(command)
			#else
			#	print "#{command}\r\n"
		end
	end

	def extract_query(text)
		begin
			m = /^.+?:(.+?)$/.match(text).captures[0].strip
			m
		rescue
			nil
		end
	end

	def extract_command(text)
		m = extract_query(text)

		if m.nil?
			nil
		else
			Command.new m
		end
	end

	def extract_item(command, text)
		m = /^.+?: #{command} (.*)$/.match(text).captures[0].strip
		m
	end

	def to_eve_price(num)
		"#{num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} ISK"
	end

	def process_price_request_system(command)
		p command
		system = command.get_argument(0, 0)

		systemId = @systems_db.get_system_id(system)
		
		if systemId.nil?
			respond("What is #{system}")
			return
		end

		by_system = Proc.new { |type_id| Net::HTTP.get("api.eve-central.com", "/api/quicklook?usesystem=#{systemId}&typeid=#{type_id}") }

		maybe_item = ""
		if command.arguments[0][0] == '"'
			idx = command.arguments[0].index('"', 1) + 1
			maybe_item = command.arguments[0][idx..-1].strip
		else
			idx = command.arguments[0].index(' ', 0)
			maybe_item = command.arguments[0][idx..-1]
		end

		maybe_item.strip!

		process_price_request(command, maybe_item, by_system, system)
	end

	def process_price_request_jita(command)
		by_jita_region = Proc.new { |type_id| Net::HTTP.get("api.eve-central.com", "/api/quicklook?regionlimit=10000002&typeid=#{type_id}") }

		process_price_request(command, command.arguments[0], by_jita_region, "Jita")
	end

	def process_price_request(command, item, querier, where)

		type_ids = @eve_db.find(item)
		
		s = ""
	
		r = ""	
		if type_ids.count != 1
			s = "Couldn't find \"#{item}\""
			r = ":\r\n"
		end
		
		if type_ids.count > 0
			s += "#{r}Did you mean:\r\n"
		end


		i = 0
		type_ids.each do |type_id|
			actual_type_id = type_id


			result = querier.call(actual_type_id)

			quick_look = EveCentral::QuickLook.new result

			lowest = quick_look.get_lowest_price

			if lowest.nil?
				s += "#{@eve_db.get_name(actual_type_id.to_i)} not available in #{where}\r\n"
			else
				s += "#{@eve_db.get_name(actual_type_id.to_i)} is #{to_eve_price(lowest)}\r\n"
			end

			i = i+1

			if i == 25
				break
			end
		end

		respond(s)
	end

	def respond(s)
		@client.message channel: @data['channel'], text: s
	end
end
