

class EveFit
	attr_accessor :unknown_items
	attr_accessor :items
	attr_accessor :quantity

	def has_unknown_items
		unknown_items.length != 0
	end

	def get_quantity(line)
		match = /^(.*?)\s+x(\d+)$/.match(line)

		if not match.nil?
			[match.captures[1].to_i, match.captures[0]]
		else
			[1, line]
		end
	end

	def initialize(evedb, fit)
		@unknown_items = []
		@items = []	
		@quantity = {}

		seen = {}

		lines = fit.split(/\r|\n/)

		lines.delete("")

		lines.each do |line|
			line.strip!

			if line.length == 0
				next
			end

			if line[0] == '['
				line = line[1..-2]
			end
			
			if line.include?(',')
				line = line.split(',')[0].strip
			end

			quantity, name = get_quantity(line)

	                possibleMatches = evedb.find(name)

			case possibleMatches.count
				when 1 then
					if seen.include? possibleMatches[0].itemId
						@quantity[seen[possibleMatches[0].itemId]] += quantity
					else
						seen[possibleMatches[0].itemId] = possibleMatches[0]
						@items.push possibleMatches[0]
						@quantity[possibleMatches[0]] = quantity
					end
				else
					if lines.count == 1
						possibleMatches.each do |m|
							@items.push m
							@quantity[m] = 1
							if @items.count > 25
								break
							end
						end
					else
						@unknown_items.push name
					end
			end
		end
	end
end

