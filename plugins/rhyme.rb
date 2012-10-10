require 'open-uri'
require 'net/http'
require 'json'
require 'uri'

class Rhyme 
	include Cinch::Plugin

	$help_messages << "!rhyme <word>  find rhymes for <word>"

	listen_to :channel
	
	def initialize(*args)
		super
	end
	
	def listen(m)
		begin
			case m.message
			when /^!rhyme help$/
				help(m)
			when /^!rhyme (\S+)$/
				get_rhymes(m,$1)
			when /^!rhyme$/
				help(m)
			end	
				
		rescue Exception => e
			error(m,e)
		end
	end

	def help(m)
		$help_messages.each {|help| m.reply(help) if help.start_with?("!rhyme")}
	end
	
	def get_rhymes(m, word)
		begin
			@words = JSON.parse open("http://rhymebrain.com/talk?function=getRhymes&word=#{word}").read
      word_array = []
			@words.each do |word_info|
				word_array << word_info["word"] if word_info["score"] == 300
			end
			m.reply "#{m.user.nick}: Words that rhyme with #{word}: #{word_array.join(", ")}" unless word_array.empty?
		rescue Exception => e
			error(m,e)
		end
	end
	
	def error(m, e)
		m.user.send "If someone could code better, we would have avoided this... (#{e.message})"
	end
	
end
