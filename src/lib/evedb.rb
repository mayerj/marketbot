require "yaml"
require "set"

class EveItem
	attr_accessor :itemId
	attr_accessor :name

	def initialize(itemId, name, parts)
		@itemId = itemId
		@name = name
		@parts = parts
	end
end

class EveDb
	def initialize(path)
		if File.exists? "../data/typeIDs.cache"
			@db = YAML::load_file("../data/typeIDs.cache")	

			allowed = Regexp.union(/\W+/, " ")
			@db_lower = {}
			@db_lower_gsub = {}
			@db.each do |k, v|
				lowercase = v.downcase
				@db_lower[k] = lowercase
				@db_lower_gsub[k] = Set.new(lowercase.gsub(allowed, ' ').split)
			end
		else
			load_db()
			save_db()
		end
	end

	def save_db()
		File.open("../data/typeIDs.cache", "w") do |file|
			file.puts YAML.dump(@db)
		end
	end
	
	def load_db()
		db = YAML::load_file("../data/typeIDs.yaml")

		map = {}
		map_lower = {}
		map_lower_gsub = {}
		
		allowed = Regexp.union(/\W+/, " ")
		
		db.each do |s|
			type_id = s[0]
			e = s[1]
			y = e["name"]
			z = y["en"]
		
			if !z.nil?
				map[type_id] = z
				map_lower[type_id] = z.downcase
				map_lower_gsub[type_id] = Set.new(z.downcase.gsub(allowed, ' ').split)
			end
		end

		@db = map
		@db_lower = map_lower
		@db_lower_gsub = map_lower_gsub

		print "Loaded #{map.count}\r\n"
	end
	
	def get_name(id)
		@db[id]
	end

	def find(item)
		ids = find_(item)
		
		allowed = Regexp.union(/\W+/, " ")

		items = []
		ids.each do |id|
			name = get_name(id)
			items.push EveItem.new id, name, name.downcase.gsub(allowed, ' ').split
		end

		items
	end

	def find_(item)
		downcased = item.downcase
		result = []
		resultAny = []
		exact = nil
		

		@db_lower.each do |k, v|
			if v == downcased
				exact = k
			end

			if v.start_with? downcased
				result.push(k)
			end

			#p k, @db_lower_gsub[k]

			if @db_lower_gsub[k].include?(downcased)
				resultAny.push(k)
			end
		end

		if !exact.nil?
			[exact]
		elsif result.count > 0
			result
		else
			resultAny
		end
	end
end


class SystemDb
	def initialize(path)
		@db = YAML::load_file("../data/systemIds.yaml")

		@by_id = {}
		@by_name = {}

		@db.each do |x|
			@by_id[x[:systemId]] = x[:name]
			@by_name[x[:name].downcase] = x[:systemId]
		end
	end

	def get_system_id(system)
		@by_name[system.downcase]
	end
end
