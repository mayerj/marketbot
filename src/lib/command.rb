
class Command
	attr_accessor :command
	attr_accessor :arguments

	def initialize(text)
		#the first string is the command
		@command = text.split[0]		
		@arguments = text[@command.length..-1].lstrip.split(/\r\n/)
	end

	def get_argument(lineno, arg)
		line = @arguments[0]

		get_single_argument(line, arg)
	end

	def get_single_argument(line, arg)
		i = 0

		while not line.nil?
			line = line.lstrip

			endIndex = -1
			if line[0] == '"'
				endIndex = line.index('"', 1) - 1
			else
				endIndex = line.index(' ', 1)

				if endIndex.nil?
					break
				end

				if line[endIndex - 1] == '"'
					endIndex = endIndex - 1;
				end
			end

			if i == arg
				if line[0] == '"'
					return line[1..endIndex].strip
				else
					return line[0..endIndex].strip
				end
			else
				i = i + 1
				endIndex = endIndex + 1

				if line[endIndex] == '"'
					endIndex = endIndex + 1
				end

				line = line[endIndex..-1]
			end
		end
	end
end
