
class Command
	attr_accessor :command
	attr_accessor :arguments
	attr_accessor :map

	def initialize(text)
		#the first string is the command
		@command = text.split[0]		
		@arguments = text[@command.length..-1].lstrip.split(/\r|\n/)

		@map = get_arg_map()
	end

	def get_line(lineno)
		if lineno == 0
			l = @arguments[0]
			m = @map[0]

			start = m[0][:start]
			return l[start..-1]
		else
			@arguments[lineno]
		end
	end

	def get_argument(lineno, arg)
		map = @map[lineno]

		get_single_argument(@arguments[lineno], map, arg)
	end

	def get_single_argument(line, map, arg)
		data = map[arg]
		return line[data[:start]..data[:end]].strip
	end

	def get_rest(lineno, after_arg)
		line = @arguments[lineno]
		map = @map[lineno]

		get_rest_line(line, map, after_arg)
	end

	def get_rest_line(line, map, after_arg)
		data = map[after_arg + 1]
		return line[data[:start]..-1].strip
	end

	def get_arg_map()
		data = []

		@arguments.each do |line|
			data.push arg_map(line)
		end

		return data	
	end

	def arg_map(line)
		map = []
		i = 0

		prevEnd = 0

		while not line.nil? and not line.empty?
			untrimmed = line
			line = line.lstrip
			
			startChars = untrimmed.length - line.length

			endIndex = -1
			if line[0] == '"'
				endIndex = line.index('"', 1) - 1
			else
				endIndex = line.index(' ', 1)

				if endIndex.nil?
					endIndex = line.length - 1
				end

				if line[endIndex - 1] == '"'
					endIndex = endIndex - 1;
				end
			end

			if line[0] == '"'
				map.push Hash[:start, 1 + prevEnd + startChars, :end, endIndex + prevEnd + startChars]
				#return line[1..endIndex].strip
			else
				map.push Hash[:start, 0 + prevEnd + startChars, :end, endIndex + prevEnd + startChars]
				#return line[0..endIndex].strip
			end
			
			i = i + 1
			endIndex = endIndex + 1

			if line[endIndex] == '"'
				endIndex = endIndex + 1
			end
			
			line = line[endIndex..-1]
			prevEnd = prevEnd + endIndex
		end

		return map
	end
end
