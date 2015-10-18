require 'net/http'
require 'nokogiri'
require './lib/evecentral'
require './lib/command'
require './lib/evefit'

class Parser
	def initialize(eve_db, systems, client, data, user_id, cache)
		@eve_db = eve_db
		@systems_db = systems
		@client = client
		@data = data
		@user_id = user_id
		@quick_look_cache = cache
	end

	def handle()
		command = extract_command(@data['text'])

		if command.nil?
			return
		end

		begin
			case command.command
				when 'price' then
					process_price_request_jita(command)
				when 'pricesystem' then
					process_price_request_system(command)
				when 'search' then
					process_search(command)
				when 'pricehub' then
					process_hub_request(command)
			end
		ensure
		end
	end

	def process_search(command)
		fit = EveFit::new @eve_db, command.arguments[0]

		respond(fit.inspect)
	end

	def extract_query(text)
		begin
			m = /^\<\@#{@user_id}\>:(.+)$/m.match(text).captures[0].strip
			m
		rescue Exception => e
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

	def self.to_eve_price(num)
		f = format("%.2f", num)

		"#{f.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} ISK"
	end

	def process_hub_request(command)
		
		maybe_items =  command.get_line(0)

		for i in 1..command.arguments.length do
			maybe_items += "\r\n#{command.arguments[i]}"
		end
		
		["Jita", "Amarr", "Hek", "Rens"].each do |system|
			process_price_request_by_system(command, maybe_items, system, @systems_db.get_system_id(system), true, false)
		end
	end

	def process_price_request_system(command)
		system = command.get_argument(0, 0)

		systemId = @systems_db.get_system_id(system)
		
		if systemId.nil?
			respond("What is #{system}")
			return
		end
		
		maybe_items =  command.get_rest(0, 0)

		for i in 1..command.arguments.length do
			maybe_items += "\r\n#{command.arguments[i]}"
		end

		process_price_request_by_system(command, maybe_items, @systems_db.get_name(systemId), systemId, true, true)
	end

	def process_price_request_by_system(command, maybe_items, system, systemId, show_total, show_breakdown)
		by_system = EveCentral::QuickLookEndpoint.new @quick_look_cache, systemId


		process_price_request(command, maybe_items, by_system.method(:get_by_system), system, show_total, show_breakdown)
	end

	def process_price_request_jita(command)
		by_jita_region = EveCentral::QuickLookEndpoint.new @quick_look_cache
		
		maybe_items = ""
		for i in 0..command.arguments.length do
			maybe_items += "\r\n#{command.arguments[i]}"
		end
		
		process_price_request(command, maybe_items, by_jita_region.method(:get_by_region_jita), "Jita", true, true)
	end

	def process_price_request(command, items, querier, where, show_total, show_breakdown)
		fit = EveFit::new @eve_db, items
		
		if fit.has_unknown_items
			response = "Couldn't identify:\r\n"
			fit.unknown_items.each do |x|
				response += "#{x}\r\n"
			end

			respond(response)
			return
		end

		prices = get_prices(fit, querier)

		sum = 0
		s = ""
		fit.items.each do |item|		
			lowest = prices[item]
			if lowest.nil?
				if show_breakdown
					s += "#{item.name} not available in #{where}\r\n"
				end
			else
				lowest = lowest * fit.quantity[item]
				sum += lowest

				howMany = ""
				if fit.quantity[item] != 1
					howMany  = "(#{fit.quantity[item]})"
				end

				if show_breakdown
					s += "#{item.name}#{howMany} is #{Parser::to_eve_price(lowest)} in #{where}\r\n"
				end
			end
		end

		if show_total
			s+= "Total: #{Parser::to_eve_price(sum)} (#{where})"
		end

		respond(s)
	end

	def get_prices(fit, querier)
		map = {}
		fit.items.each do |item|
			quick_look = querier.call(item.itemId)

			lowest = quick_look.get_lowest_price

			map[item] = lowest
		end

		map
	end

	def respond(s)
		@client.message channel: @data['channel'], text: s
	end
end
