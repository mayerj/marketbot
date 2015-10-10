require "yaml"

class EveDb
	def initialize(path)
		if File.exists? "../data/typeIDs.cache"
			@db = YAML::load_file("../data/typeIDs.cache")	

			@db_lower = {}
			@db.each do |k, v|
				@db_lower[k] = v.downcase
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
		
		db.each do |s|
			type_id = s[0]
			e = s[1]
			y = e["name"]
			z = y["en"]
		
			if !z.nil?
				map[type_id] = z
				map_lower[type_id] = z.downcase
			end
		end

		@db = map
		@db_lower = map_lower

		print "Loaded #{map.count}\r\n"
	end
	
	def get_name(id)
		@db[id]
	end

	def find(item)
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
			
			allowed = Regexp.union(/\W+/, " ")
#			puts v.gsub(allowed, ' ')	
			if v.gsub(allowed, ' ').split.include?(downcased)
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
