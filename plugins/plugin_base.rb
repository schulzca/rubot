require 'open-uri'
require 'net/http'
require 'json'
require 'uri'

class PluginBase
	include Cinch::Plugin
	
	def help(m,prefix)
		$help_messages.each {|help| m.reply(help) if help.start_with?(prefix)}
	end
	
	def error(m,e)
		User($master).send "Be vigilant! (#{e.message})"
	end
end
