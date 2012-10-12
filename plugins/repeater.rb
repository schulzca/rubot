class Repeater < PluginBase
  include Cinch::Plugin
	listen_to :channel
	listen_to :private
  $help_messages << "#{$settings['settings']['nick']}: ping everyone in the room"
  $help_messages << "all: <message>   ping everyone in the room"

  @repeater = nil
  def nicks(m)
    names = m.channel.users.keys.map(&:nick).reject{|n|[$settings['settings']['nick'],m.user.nick].include?(n)}
    names.join(' ') unless names.empty?
  end

  def listen(m)
	unless @repeater
		@repeater = true
		case m.message
		when /^all:/
		  n = nicks(m)
		  if n and not n.match(/the_donbot/)
        m.reply "#{nicks(m)}: ^"
		  end
		when /^#{$settings['settings']['nick']}.*ping/
		  n = nicks(m)
		  if n and not n.match(/the_donbot/)
        m.reply "#{nicks(m)}: ping"
		  end
		end
		@repeater = nil
	end
  end

end
