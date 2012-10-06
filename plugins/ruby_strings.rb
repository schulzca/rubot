class RubyStrings
	include Cinch::Plugin

	$help_messages << "!str:<method> <string message>     call a ruby string method on your message (currently no params)"

	listen_to :channel
	
	def listen(m)
		begin
			case m.message
			when /^!str:(\S+)\s+(.*)$/
				m.reply "#{$2.send($1)}"
			when /^!str\s*$/
				m.reply "Try: !str:<method> <string message>"
			end
		rescue Exception => e
			m.reply "No can do. (#{e.message})"
		end
	end
end
				
		
	
