class Messaging < PluginBase
  include Cinch::Plugin

  $help_messages << ["msg","!msg <user> <text>   Send a message to offline users. They will receive it when they are online."]

	listen_to :channel
	listen_to :private

	@@json = nil

	def initialize(*args)
	  super
    @@json ||= {}
  end

	def react_to_message(m)
	  if @@json
			begin
				case m.message
				when /^!msg (\S+) (.+)$/
          store_message(m, $1, $2)
  			end
  			if(m.user)
          check_user_mailbox(m, m.user.nick)
        end
			rescue Exception => e
				error(m,e)
			end
		end
	end

	def check_user_mailbox(m, nick)
     if @@json[nick]
       send_messages(m,nick)
     end
  end
	
	def store_message(m, nick, message)
	  memo = "[#{Time.now.strftime("%b %d %I:%M %p")}] From #{m.user.nick}: #{message}"
     if @@json[nick]
       @@json[nick] << memo 
     else
       @@json[nick] = [memo]
     end
  end

	def send_messages(m,nick)  
	  @@json[nick].each do |key, val|
      pm m.user,@@json[nick].delete(key).to_s
    end
	end
end
