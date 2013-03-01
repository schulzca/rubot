class Help < PluginBase
  include Cinch::Plugin

	listen_to :channel
	listen_to :private

	def react_to_message(m)
	  if active?(m,"help")
			begin
				case m.message
				when /^!help$/
					display_help(m)
  			end
			rescue Exception => e
				error(m,e)
			end
    end
	end
	
	def display_help(m)
    topics = $help_messages.map{|message| message.split(/\s+/)[0].gsub(/[!:]/,"") }.uniq
    pm(m.user, "Available topics: #{topics.join(", ")}\nLearn more with '!help <topic>'")
	end
end
