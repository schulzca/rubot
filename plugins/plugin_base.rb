require 'open-uri'
require 'net/http'
require 'json'
require 'uri'

class PluginBase
	include Cinch::Plugin
	
	def help(m,prefix)
		$help_messages.each {|help| m.user.send(help) if help.start_with?(prefix)}
	end
	
	def error(m,e)
		User($master).send "Be vigilant! (#{e.message})\n#{e.backtrace.join("\n")}"
	end
end
