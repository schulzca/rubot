require 'stringio'
class Eval 
	include Cinch::Plugin

	$help_messages << "!eval <message>  Eval one line of ruby"

	listen_to :channel
	
	def listen(m)
		begin
			case m.message
			when /^!eval( help)?$/
				help(m)
			when /^!eval (.*)$/
				eval_message(m,$1)
			end
		rescue Exception => e
			m.reply "Learn your rubies. (#{e.message})"
			$stdout = STDOUT
		end
	end
	
	def help(m)
		$help_messages.each {|help| m.reply(help) if help.start_with? "!eval" }
	end
	
	def eval_message(m, code)
		capture = StringIO.new
		$stdout = capture
		result = "#{eval(code)}"
		m.reply(capture.string) unless capture.length == 0
		m.reply "=> #{result}"
		$stdout = STDOUT
	end
end
