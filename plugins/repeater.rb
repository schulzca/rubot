class Repeater < PluginBase
  include Cinch::Plugin
	listen_to :channel
	listen_to :private
  $help_messages << ["repeater","all: <message>   ping everyone in the room"]

  def nicks(m)
    names = m.channel.users.keys.map(&:nick).reject{|n|[$settings['settings']['nick'],m.user.nick].include?(n)}
    names.join(' ') unless names.empty?
  end

  def react_to_message(m)
    if active?(m,"repeater")
      begin
        case m.message
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
      reply m,"#{nicks(m)}:#{message}"
    else
      reply m,"We're the only ones here..."
    end
  end
end
