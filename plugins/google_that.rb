class GoogleThat < PluginBase
  include Cinch::Plugin
  require 'open-uri'

	$help_messages << ["google that","!gt <text>   Generate a lmgtfy link for <text>"]

	listen_to :channel
	listen_to :private
	
	def react_to_message(m)
	  if active?(m,"google_that")
			begin
				case m.message
				when /^!gt (.+)$/
				  generate_link(m,$1)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def generate_link(m,message)
	  url = "http://lmgtfy.com?q=#{message}"
		url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
		if url != "Error"
      reply(m,"#{m.user.nick}: #{url}")
    end
	end
end
