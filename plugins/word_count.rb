class WordCount < PluginBase
  include Cinch::Plugin

	$help_messages << "!wordcount   supply a username for their count or 'leader' for the current leader"

	listen_to :channel
	listen_to :private
	
  @@json = nil
  def initialize(*args)
    super
    unless @@json
      @@json = JSON.parse open($settings["settings"]["wordcount_path"]).read
    end
  end
	
	def react_to_message(m)
	  if active?(m,"word_count")
      if m.user != "nickserv"
        begin
          update_tracker(m)
          case m.message
          when /^!help (wordcount|wc)$/
            help(m, "!wordcount")
          when /^!(wordcount|wc)(\s+leader)?$/
            display_leader(m)
          when /^!(wordcount|wc)\s+(.+)$/
            display_count(m,$2)
          end
          write_tracker
        rescue Exception => e
          error(m,e)
        end
      end
    end
	end

	def write_tracker
    unless $writing_to_file
      $writing_to_file = true
      File.open($settings["settings"]["wordcount_path"], 'w'){|f|f.write(@@json.to_json)}
      $writing_to_file = false
    end
  end
	
	def update_tracker(m)
	  if m.user
      count = get_count_for_nick(m, m.user.nick)
      if count
        @@json[m.user.nick]["count"] = count + m.message.split(/\s+/).count
        @@json[m.user.nick]["channel"] = m.channel.name if m.channel
      end
    end
  end
	
  def display_leader(m)
    name = nil
    words = 0
    channel = @@json[m.user.nick]["channel"]
    @@json.each do |nick, entry|
      channel_check = channel == entry["channel"] or !channel
      wc = get_count_for_nick(m,nick)
      if wc > words and channel_check
        words = wc
        name = nick
      end
    end
    reply m, "#{name} is in the lead with #{words} words."
  end

	def display_count(m,nick)
    count = get_count_for_nick(m,nick)
    if count
      reply m, "#{nick} has typed #{count} words."
    else
      reply m, "#{nick} is not here."
    end
  end

  def get_count_for_nick(m,nick)
    if @@json[nick] and @@json[nick]["count"]
      count = @@json[nick]["count"]
    elsif m.channel and m.channel.users.collect{|u| u.first.nick}.include? nick
      @@json[nick] = {"count" => 0, "channel" => m.channel.name}
      count = 0
    else 
      @@json[nick] = {"count" => 0}
      count = 0
    end
  end
end

