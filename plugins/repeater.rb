class Repeater < PluginBase
  include Cinch::Plugin
	listen_to :channel
	listen_to :private
  $help_messages << "#{$settings['settings']['nick']}: ping everyone in the room"
  $help_messages << "all: <message>   ping everyone in the room"

  def nicks(m)
    names = m.channel.users.keys.map(&:nick).reject{|n|[$settings['settings']['nick'],m.user.nick].include?(n)}
    names.join(' ') unless names.empty?
  end
  $repeater_config = nil

  def listen(m)
    begin
      $repeater_config ||= {}
      case m.message
      when /^all:(.*)$/
        ping_all(m, $1)
      when /^all off:$/
        turn_off(m, m.channel)
      when /^all on:$/
        turn_on(m,m.channel)
      end
    rescue Exception => e
      error(m,e)
    end
  end

  def ping_all(m, message)
    if m.channel
      if $repeater_config[m.channel.name]
        n = nicks(m)
        m.reply "#{nicks(m)}:#{message}"
      end
    else
      m.reply "We're the only ones here..."
    end
  end

  def turn_off(m, channel)
    if channel
      $repeater_config[channel.name] = false
      m.reply "Repeater turned off."
    else
      m.reply "Please do that in a channel."
    end
  end

  def turn_on(m, channel)
    if channel
      $repeater_config[channel.name] = true
      m.reply "Repeater turned on."
    else
      m.reply "Please do that in a channel."
    end
  end
end
