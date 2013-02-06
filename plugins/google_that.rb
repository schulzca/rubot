class GoogleThat < PluginBase
  include Cinch::Plugin
  require 'open-uri'

	$help_messages << "!gt <username> <text>   pm rubot to have him send a lmgtfy link to someone in shared channels"

	listen_to :channel
	listen_to :private

	@@channels = nil
	
	def react_to_message(m)
	  if active?(m,"google_that")
      @@channels ||= {}
      track_channels(m)
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
	
	def track_channels(m)
    @@channels[m.channel.to_s] = m
  end

	def generate_link(m,user,message)
	  url = "http://lmgtfy.com?q=#{message}"
		url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
		if url != "Error"
      @@channels.each do |c,m2|
        if m2.channel
          users = m2.channel.users.collect{|u| u.first.nick}
          if users.include? m.user.nick and users.include? user
            reply m2,"#{user}: #{url}"
          end
        end
      end
    end
	end
end
