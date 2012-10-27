class Messaging < PluginBase
  include Cinch::Plugin

  $help_messages << "!msg         send a message to offline users. They will receive them when they log back on."

	listen_to :channel
	listen_to :private

	def initialize(*args)
    $json ||= {}
	  super
  end

	def listen(m)
	  if $json
			begin
				case m.message
				when /^!msg( help)?$/
					help(m, "!msg")
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
     if $json[nick]
       send_messages(m,nick)
     end
  end
	
	def store_message(m, nick, message)
	  memo = "[#{Time.now.strftime("%b %d %I:%M %p")}] From #{m.user.nick}: #{message}"
     if $json[nick]
       $json[nick] << memo 
     else
       $json[nick] = [memo]
     end
  end

	def send_messages(m,nick)  
	  $json[nick].each do |key, val|
      m.user.send $json[nick].delete(key).to_s
    end
	end
end
