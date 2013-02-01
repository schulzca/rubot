class Repeater < PluginBase
  include Cinch::Plugin
	listen_to :channel
	listen_to :private
  $help_messages << "all: <message>   ping everyone in the room"

  def nicks(m)
    names = m.channel.users.keys.map(&:nick).reject{|n|[$settings['settings']['nick'],m.user.nick].include?(n)}
    names.join(' ') unless names.empty?
  end

  def listen(m)
    if active?(m,"repeater")
      begin
        case m.message
        when /^!help all$/
          help(m,"all:")
        when /^all:(.*)$/
          ping_all(m, $1)
        end
      rescue Exception => e
        error(m,e)
      end
    end
  end

  def ping_all(m, message)
    if m.channel
      n = nicks(m)
      m.reply "#{nicks(m)}:#{message}"
    else
      m.reply "We're the only ones here..."
    end
  end
end
