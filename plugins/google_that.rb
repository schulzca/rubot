class GoogleThat < PluginBase
  include Cinch::Plugin
  require 'open-uri'

	$help_messages << "!gt <username> <text>   pm rubot to have him send a lmgtfy link to someone in shared channels"

	listen_to :channel
	listen_to :private
	
	def react_to_message(m)
	  if active?(m,"google_that")
			begin
				case m.message
				when /^!help gt$/
					help(m, "!gt")
				when /^!gt (\S+)\s+(.*)$/
				  generate_link(m,$1,$2)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def generate_link(m,user,message)
	  url = "http://lmgtfy.com?q=#{message}"
		url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
		if url != "Error"
      broadcast(m,user,url)
    end
	end
end
